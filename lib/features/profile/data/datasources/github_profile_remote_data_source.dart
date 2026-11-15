import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../matching/domain/entities/github_scan_result.dart';
import '../exceptions/github_profile_exceptions.dart';

/// Live public GitHub profile scan for Connect GitHub.
///
/// Optional token raises rate limits:
/// ```sh
/// flutter run --dart-define=GITHUB_TOKEN=ghp_xxx
/// ```
class GithubProfileRemoteDataSource {
  GithubProfileRemoteDataSource({
    http.Client? client,
    String? token,
    Duration timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client(),
       _token = token ?? const String.fromEnvironment('GITHUB_TOKEN'),
       _timeout = timeout;

  final http.Client _client;
  final String _token;
  final Duration _timeout;

  Future<GithubScanResult> scan(String username) async {
    final login = username.trim();
    if (login.isEmpty) {
      throw const GithubProfileException('GitHub username is required');
    }

    try {
      final userResponse = await _get(Uri.https('api.github.com', '/users/$login'));
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

      final languageCounts = await _languageCounts(canonical);
      final percents = _toPercents(languageCounts);
      final languages = percents.keys.toList(growable: false);
      final commits = await _commitsLastYear(canonical);

      return GithubScanResult(
        username: canonical,
        publicRepos: publicRepos,
        languages: languages,
        languagePercents: percents,
        commitsLastYear: commits,
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

  Future<Map<String, int>> _languageCounts(String login) async {
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

  Future<int> _commitsLastYear(String login) async {
    try {
      final since = DateTime.now()
          .toUtc()
          .subtract(const Duration(days: 365))
          .toIso8601String()
          .split('T')
          .first;
      final response = await _get(
        Uri.https('api.github.com', '/search/commits', {
          'q': 'author:$login+committer-date:>$since',
          'per_page': '1',
        }),
      );
      if (response.statusCode != 200) return 0;

      final payload =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return (payload['total_count'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
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

  Future<http.Response> _get(Uri uri) {
    return _client
        .get(
          uri,
          headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
            if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
          },
        )
        .timeout(_timeout);
  }
}
