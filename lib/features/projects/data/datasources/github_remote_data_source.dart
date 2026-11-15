import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../exceptions/projects_exceptions.dart';
import '../models/project_model.dart';

/// Fetches live repository metrics from the public GitHub REST API.
///
/// The DevSync API also syncs these values into `projects/{id}.github`; this
/// source is used opportunistically on the details screen when the cache is
/// stale. A token can be supplied at build time to raise the rate limit:
///
/// ```sh
/// flutter run --dart-define=GITHUB_TOKEN=ghp_xxx
/// ```
class GithubRemoteDataSource {
  GithubRemoteDataSource({
    http.Client? client,
    String? token,
    Duration timeout = const Duration(seconds: 8),
  }) : _client = client ?? http.Client(),
       _token = token ?? const String.fromEnvironment('GITHUB_TOKEN'),
       _timeout = timeout;

  final http.Client _client;
  final String _token;
  final Duration _timeout;

  Future<GithubMetricsModel> fetchMetrics(String githubUrl) async {
    final repo = _GithubRepo.parse(githubUrl);
    if (repo == null) {
      throw const GithubUnavailableException('Invalid GitHub repository URL');
    }

    final repoResponse = await _get(
      Uri.https('api.github.com', '/repos/${repo.fullName}'),
    );
    if (repoResponse.statusCode == 404) {
      throw const GithubUnavailableException('Repository not found on GitHub');
    }
    if (repoResponse.statusCode != 200) {
      throw GithubUnavailableException(
        'GitHub request failed (${repoResponse.statusCode})',
      );
    }

    final payload =
        jsonDecode(utf8.decode(repoResponse.bodyBytes)) as Map<String, dynamic>;
    final contributors = await _contributorsCount(repo.fullName);

    return GithubMetricsModel(
      stars: (payload['stargazers_count'] as num?)?.toInt() ?? 0,
      contributors: contributors,
      // GitHub counts issues and pull requests together here. The details
      // screen labels it "Open tasks"; the DevSync API can refine it later.
      openTasks: (payload['open_issues_count'] as num?)?.toInt() ?? 0,
      syncedAt: DateTime.now(),
    );
  }

  Future<int> _contributorsCount(String fullName) async {
    try {
      final response = await _get(
        Uri.https('api.github.com', '/repos/$fullName/contributors', {
          'per_page': '1',
          'anon': '1',
        }),
      );
      if (response.statusCode != 200) return 0;

      final lastPage = _lastPageFromLink(response.headers['link']);
      if (lastPage != null) return lastPage;

      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      return payload is List ? payload.length : 0;
    } catch (_) {
      return 0;
    }
  }

  int? _lastPageFromLink(String? link) {
    if (link == null || link.isEmpty) return null;
    final match = RegExp(r'[?&]page=(\d+)>;\s*rel="last"').firstMatch(link);
    return int.tryParse(match?.group(1) ?? '');
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

class _GithubRepo {
  const _GithubRepo(this.owner, this.name);

  final String owner;
  final String name;

  String get fullName => '$owner/$name';

  static _GithubRepo? parse(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.host.toLowerCase().contains('github.com')) {
      return null;
    }
    final segments = uri.pathSegments
        .where((segment) => segment.trim().isNotEmpty)
        .toList(growable: false);
    if (segments.length < 2) return null;

    var name = segments[1];
    if (name.toLowerCase().endsWith('.git')) {
      name = name.substring(0, name.length - 4);
    }
    if (name.isEmpty) return null;
    return _GithubRepo(segments[0], name);
  }
}
