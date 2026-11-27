import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../exceptions/github_profile_exceptions.dart';

class GithubEvent {
  const GithubEvent({
    required this.type,
    required this.repo,
    required this.createdAt,
  });

  final String type;
  final String repo;
  final DateTime createdAt;
}

class GithubPeriodCounts {
  const GithubPeriodCounts({
    required this.prsMerged,
    required this.commits,
    required this.reviews,
  });

  final int prsMerged;
  final int commits;
  final int reviews;
}

class InsightsRemoteDataSource {
  InsightsRemoteDataSource({
    http.Client? client,
    Future<String?> Function()? tokenProvider,
    String? token,
    Duration timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client(),
       _tokenProvider = tokenProvider,
       _tokenOverride = token ?? const String.fromEnvironment('GITHUB_TOKEN'),
       _timeout = timeout;

  final http.Client _client;
  final Future<String?> Function()? _tokenProvider;
  final String _tokenOverride;
  final Duration _timeout;

  Future<String> _resolveToken() async {
    if (_tokenOverride.trim().isNotEmpty) return _tokenOverride.trim();
    final fromStore = await _tokenProvider?.call();
    return fromStore?.trim() ?? '';
  }

  Future<List<GithubEvent>> fetchEvents(String username) {
    return _guard(() async {
      final login = _requireLogin(username);
      final events = <GithubEvent>[];

      for (var page = 1; page <= 3; page++) {
        final response = await _get(
          Uri.https('api.github.com', '/users/$login/events/public', {
            'per_page': '100',
            'page': '$page',
          }),
        );
        if (response.statusCode == 404) {
          throw const GithubUserNotFoundException();
        }
        if (response.statusCode != 200) {
          if (page == 1) _throwForStatus(response.statusCode);
          break;
        }

        final payload = jsonDecode(utf8.decode(response.bodyBytes));
        if (payload is! List || payload.isEmpty) break;

        for (final item in payload) {
          if (item is! Map<String, dynamic>) continue;
          final type = item['type'];
          final created = DateTime.tryParse('${item['created_at']}');
          final repo = (item['repo'] as Map?)?['name'];
          if (type is! String || created == null || repo is! String) continue;
          events.add(
            GithubEvent(type: type, repo: repo, createdAt: created.toUtc()),
          );
        }

        if (payload.length < 100) break;
      }
      return events;
    });
  }

  Future<GithubPeriodCounts> fetchCounts(String username, DateTime since) {
    return _guard(() async {
      final login = _requireLogin(username);
      final date = since.toUtc().toIso8601String().split('T').first;

      final results = await Future.wait([
        _searchCount(
          '/search/issues',
          'author:$login type:pr is:merged merged:>=$date',
        ),
        _searchCount('/search/commits', 'author:$login committer-date:>=$date'),
        // Approximation: PRs you reviewed that had activity in the period.
        _searchCount(
          '/search/issues',
          'reviewed-by:$login type:pr updated:>=$date',
        ),
      ]);

      return GithubPeriodCounts(
        prsMerged: results[0],
        commits: results[1],
        reviews: results[2],
      );
    });
  }

  Future<int> _searchCount(String path, String query) async {
    final response = await _get(
      Uri.https('api.github.com', path, {'q': query, 'per_page': '1'}),
    );
    if (response.statusCode == 403 || response.statusCode == 429) {
      throw const GithubProfileException(
        'GitHub rate limit reached. Try again in a minute.',
      );
    }

    if (response.statusCode != 200) return 0;

    final payload = jsonDecode(utf8.decode(response.bodyBytes));
    if (payload is! Map<String, dynamic>) return 0;
    return (payload['total_count'] as num?)?.toInt() ?? 0;
  }

  String _requireLogin(String username) {
    final login = username.trim();
    if (login.isEmpty) {
      throw const GithubProfileException('GitHub username is required');
    }
    return login;
  }

  Never _throwForStatus(int status) {
    if (status == 403 || status == 429) {
      throw const GithubProfileException(
        'GitHub rate limit reached. Try again in a minute.',
      );
    }
    throw GithubProfileException('GitHub request failed ($status)');
  }

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
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

  Future<http.Response> _get(Uri uri) async {
    final token = await _resolveToken();
    return _client
        .get(
          uri,
          headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(_timeout);
  }
}
