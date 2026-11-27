import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../matching/domain/entities/github_scan_result.dart';
import '../../domain/entities/profile.dart';
import '../exceptions/github_profile_exceptions.dart';

/// Live public GitHub profile scan for Connect GitHub.
///
/// Prefers the signed-in user's OAuth token (via [tokenProvider]). Optional
/// dart-define override for CI/tests:
/// ```sh
/// flutter run --dart-define=GITHUB_TOKEN=ghp_xxx
/// ```
class GithubProfileRemoteDataSource {
  GithubProfileRemoteDataSource({
    http.Client? client,
    Future<String?> Function()? tokenProvider,
    Future<void> Function()? onInvalidToken,
    String? token,
    Duration timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client(),
       _tokenProvider = tokenProvider,
       _onInvalidToken = onInvalidToken,
       _tokenOverride = token ?? const String.fromEnvironment('GITHUB_TOKEN'),
       _timeout = timeout;

  final http.Client _client;
  final Future<String?> Function()? _tokenProvider;
  final Future<void> Function()? _onInvalidToken;
  final String _tokenOverride;
  final Duration _timeout;

  static const _bioLimit = 140;
  static const _graphqlUri = 'https://api.github.com/graphql';

  Future<GithubScanResult> scan(String username) async {
    final login = username.trim();
    if (login.isEmpty) {
      throw const GithubProfileException('GitHub username is required');
    }

    try {
      // Stale OAuth tokens return 401 even on public endpoints — drop and retry.
      var token = await _resolveToken();
      var userResponse = await _get(
        Uri.https('api.github.com', '/users/$login'),
        token: token,
      );
      if (userResponse.statusCode == 401 && token.isNotEmpty) {
        await _dropInvalidToken();
        token = '';
        userResponse = await _get(
          Uri.https('api.github.com', '/users/$login'),
          token: token,
        );
      }
      if (userResponse.statusCode == 404) {
        throw const GithubUserNotFoundException();
      }
      if (userResponse.statusCode != 200) {
        throw GithubProfileException(
          'GitHub request failed (${userResponse.statusCode})',
        );
      }

      final user =
          jsonDecode(utf8.decode(userResponse.bodyBytes)) as Map<String, dynamic>;
      final publicRepos = (user['public_repos'] as num?)?.toInt() ?? 0;
      final canonical =
          (user['login'] as String?)?.trim().isNotEmpty == true
          ? (user['login'] as String).trim()
          : login;
      final githubBio = _cleanBio(user['bio'] as String?);

      final languageCounts = await _languageCounts(canonical, token: token);
      final percents = _toPercents(languageCounts);
      final languages = percents.keys.toList(growable: false);

      final contributions = await _contributionsLastYear(
        canonical,
        token: token,
      );
      final bioSuggestion =
          await _profileReadmeBio(canonical, token: token) ?? githubBio;

      return GithubScanResult(
        username: canonical,
        publicRepos: publicRepos,
        languages: languages,
        languagePercents: percents,
        commitsLastYear: contributions.commits,
        bioSuggestion: bioSuggestion,
        activity: contributions.activity,
      );
    } on GithubProfileException {
      rethrow;
    } on SocketException {
      throw const GithubProfileNetworkException();
    } on TimeoutException {
      throw const GithubProfileNetworkException();
    } on http.ClientException {
      throw const GithubProfileNetworkException();
    }
  }

  Future<String> _resolveToken() async {
    if (_tokenOverride.trim().isNotEmpty) return _tokenOverride.trim();
    final fromStore = await _tokenProvider?.call();
    return fromStore?.trim() ?? '';
  }

  Future<void> _dropInvalidToken() async {
    if (_tokenOverride.trim().isNotEmpty) return;
    await _onInvalidToken?.call();
  }

  Future<Map<String, int>> _languageCounts(
    String login, {
    required String token,
  }) async {
    final counts = <String, int>{};
    var page = 1;

    while (page <= 3) {
      final response = await _get(
        Uri.https('api.github.com', '/users/$login/repos', {
          'per_page': '100',
          'type': 'owner',
          'sort': 'updated',
          'page': '$page',
        }),
        token: token,
      );
      if (response.statusCode != 200) break;

      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is! List || payload.isEmpty) break;

      for (final item in payload) {
        if (item is! Map<String, dynamic>) continue;
        final language = item['language'];
        if (language is! String || language.trim().isEmpty) continue;
        final name = language.trim();
        counts[name] = (counts[name] ?? 0) + 1;
      }

      if (payload.length < 100) break;
      page++;
    }

    return counts;
  }

  Future<_ContributionStats> _contributionsLastYear(
    String login, {
    required String token,
  }) async {
    if (token.isNotEmpty) {
      final graphql = await _commitsViaGraphql(login, token: token);
      if (graphql != null) return graphql;
    }
    final commits = await _commitsViaSearch(login, token: token);
    return _ContributionStats(commits: commits, activity: const []);
  }

  Future<_ContributionStats?> _commitsViaGraphql(
    String login, {
    required String token,
  }) async {
    const query = r'''
query($login: String!) {
  user(login: $login) {
    contributionsCollection {
      totalCommitContributions
      contributionCalendar {
        weeks {
          contributionDays { contributionCount }
        }
      }
    }
  }
}
''';

    final response = await _client
        .post(
          Uri.parse(_graphqlUri),
          headers: {
            'Accept': 'application/vnd.github+json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'X-GitHub-Api-Version': '2022-11-28',
          },
          body: jsonEncode({
            'query': query,
            'variables': {'login': login},
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw GithubProfileException(
        'GitHub contributions failed (${response.statusCode})',
      );
    }

    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (payload['errors'] is List && (payload['errors'] as List).isNotEmpty) {
      return null;
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) return null;
    final user = data['user'];
    if (user is! Map<String, dynamic>) {
      throw const GithubUserNotFoundException();
    }

    final collection = user['contributionsCollection'];
    if (collection is! Map<String, dynamic>) return null;

    final commits =
        (collection['totalCommitContributions'] as num?)?.toInt() ?? 0;
    final calendar = collection['contributionCalendar'];
    final activity = _activityFromCalendar(calendar);

    return _ContributionStats(commits: commits, activity: activity);
  }

  Future<int> _commitsViaSearch(
    String login, {
    required String token,
  }) async {
    final since = DateTime.now()
        .toUtc()
        .subtract(const Duration(days: 365))
        .toIso8601String()
        .split('T')
        .first;

    // Spaces between search terms — Uri encodes them as %20 (not literal +).
    final response = await _get(
      Uri.https('api.github.com', '/search/commits', {
        'q': 'author:$login committer-date:>$since',
        'per_page': '1',
      }),
      token: token,
      accept: 'application/vnd.github.cloak-preview+json',
    );

    if (response.statusCode == 403 || response.statusCode == 429) {
      throw const GithubProfileException(
        'GitHub rate limit hit while counting commits. Try again later.',
      );
    }
    if (response.statusCode != 200) {
      throw GithubProfileException(
        'Could not load commits (${response.statusCode})',
      );
    }

    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return (payload['total_count'] as num?)?.toInt() ?? 0;
  }

  Future<String?> _profileReadmeBio(
    String login, {
    required String token,
  }) async {
    final response = await _get(
      Uri.https('api.github.com', '/repos/$login/$login/readme'),
      token: token,
    );
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) return null;

    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final encoding = (payload['encoding'] as String?)?.toLowerCase();
    final content = payload['content'] as String?;
    if (content == null || content.isEmpty) return null;

    String raw;
    if (encoding == 'base64') {
      final cleaned = content.replaceAll(RegExp(r'\s'), '');
      raw = utf8.decode(base64.decode(cleaned));
    } else {
      raw = content;
    }

    return _cleanBio(raw);
  }

  String? _cleanBio(String? raw) {
    if (raw == null) return null;
    var text = raw
        .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
        .replaceAll(RegExp(r'`[^`]*`'), ' ')
        .replaceAll(RegExp(r'!\[([^\]]*)\]\([^)]*\)'), r'$1')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]*\)'), r'$1')
        .replaceAll(RegExp(r'[#>*_\-~|]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty) return null;
    if (text.length <= _bioLimit) return text;
    return '${text.substring(0, _bioLimit - 1).trimRight()}…';
  }

  List<List<int>> _activityFromCalendar(Object? calendar) {
    if (calendar is! Map<String, dynamic>) return const [];
    final weeks = calendar['weeks'];
    if (weeks is! List || weeks.isEmpty) return const [];

    final dayCounts = <int>[];
    for (final week in weeks) {
      if (week is! Map<String, dynamic>) continue;
      final days = week['contributionDays'];
      if (days is! List) continue;
      for (final day in days) {
        if (day is! Map<String, dynamic>) continue;
        dayCounts.add((day['contributionCount'] as num?)?.toInt() ?? 0);
      }
    }
    if (dayCounts.isEmpty) return const [];

    final needed = Profile.maxWeeks * Profile.days;
    final slice = dayCounts.length <= needed
        ? dayCounts
        : dayCounts.sublist(dayCounts.length - needed);

    final weekCount = (slice.length / Profile.days)
        .ceil()
        .clamp(1, Profile.maxWeeks)
        .toInt();
    final padded = List<int>.filled(weekCount * Profile.days, 0);
    final offset = padded.length - slice.length;
    for (var i = 0; i < slice.length; i++) {
      padded[offset + i] = _intensity(slice[i]);
    }

    return List.generate(
      weekCount,
      (w) => List.generate(
        Profile.days,
        (d) => padded[w * Profile.days + d],
      ),
    );
  }

  int _intensity(int count) {
    if (count <= 0) return 0;
    if (count <= 2) return 1;
    if (count <= 5) return 2;
    if (count <= 10) return 3;
    return 4;
  }

  Map<String, int> _toPercents(Map<String, int> counts) {
    if (counts.isEmpty) return const {};

    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.compareTo(b.key);
      });

    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    if (total <= 0) return const {};

    final result = <String, int>{};
    var used = 0;
    for (var i = 0; i < entries.length; i++) {
      final isLast = i == entries.length - 1;
      final percent = isLast
          ? 100 - used
          : ((entries[i].value * 100) / total).round();
      used += percent;
      result[entries[i].key] = percent;
    }
    return result;
  }

  Future<http.Response> _get(
    Uri uri, {
    required String token,
    String accept = 'application/vnd.github+json',
  }) {
    return _client
        .get(
          uri,
          headers: {
            'Accept': accept,
            'X-GitHub-Api-Version': '2022-11-28',
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(_timeout);
  }
}

class _ContributionStats {
  const _ContributionStats({
    required this.commits,
    required this.activity,
  });

  final int commits;
  final List<List<int>> activity;
}
