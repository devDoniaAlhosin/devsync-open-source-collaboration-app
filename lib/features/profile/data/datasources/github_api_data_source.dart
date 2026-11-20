import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Data source for fetching GitHub repository data via GitHub REST API.
abstract class GitHubApiDataSource {
  /// Fetches the top repositories for a given username, sorted by stars.
  ///
  /// Returns a list of repository URLs (e.g., ['https://github.com/user/repo1', ...]).
  /// Returns empty list if user has no repos or on error (graceful degradation).
  ///
  /// [limit] determines maximum number of repositories to return (default: 5).
  Future<List<String>> getTopRepositories(String username, {int limit = 5});
}

/// Implementation of [GitHubApiDataSource] using GitHub REST API v3.
///
/// GitHub API Rate Limits:
/// - Unauthenticated: 60 requests/hour
/// - Authenticated (with token): 5000 requests/hour
///
/// For production, consider adding a GitHub personal access token via
/// dart-define or environment variable to increase rate limits.
class GitHubRestApiDataSource implements GitHubApiDataSource {
  GitHubRestApiDataSource({HttpClient? httpClient, this.token})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  /// Optional GitHub personal access token for higher rate limits.
  /// If null, uses unauthenticated API (60 req/hour).
  final String? token;

  static const String _baseUrl = 'api.github.com';
  static const String _userAgent = 'DevSync-Flutter-App';
  static const Duration _timeout = Duration(seconds: 10);

  @override
  Future<List<String>> getTopRepositories(
    String username, {
    int limit = 5,
  }) async {
    if (username.isEmpty) {
      return [];
    }

    try {
      // Fetch user's repositories
      // GET /users/{username}/repos?sort=updated&per_page={limit}
      final uri = Uri.https(_baseUrl, '/users/$username/repos', {
        'sort': 'updated', // Sort by last updated (most active)
        'per_page': limit.toString(),
        'type': 'owner', // Only repos the user owns (not forks)
      });

      final request = await _httpClient.getUrl(uri).timeout(_timeout);

      // Set headers
      request.headers.set('User-Agent', _userAgent);
      request.headers.set('Accept', 'application/vnd.github.v3+json');

      // Add auth token if available
      if (token != null && token!.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $token');
      }

      final response = await request.close().timeout(_timeout);

      if (response.statusCode == 200) {
        final body = await response
            .transform(utf8.decoder)
            .join()
            .timeout(_timeout);

        final List<dynamic> repos = jsonDecode(body) as List<dynamic>;

        // Sort by stars (stargazers_count) and take top N
        repos.sort((a, b) {
          final aStars =
              (a as Map<String, dynamic>)['stargazers_count'] as int? ?? 0;
          final bStars =
              (b as Map<String, dynamic>)['stargazers_count'] as int? ?? 0;
          return bStars.compareTo(aStars); // Descending order
        });

        // Extract HTML URLs
        final topRepos = repos
            .take(limit)
            .map((repo) {
              final data = repo as Map<String, dynamic>;
              return data['html_url'] as String? ?? '';
            })
            .where((url) => url.isNotEmpty)
            .toList();

        return topRepos;
      } else if (response.statusCode == 404) {
        // User not found or has no public repos
        return [];
      } else if (response.statusCode == 403) {
        // Rate limit exceeded
        // TODO: Consider logging this for monitoring
        return [];
      } else {
        // Other errors (500, etc.)
        return [];
      }
    } on SocketException {
      // Network error - graceful degradation
      return [];
    } on TimeoutException {
      // Request timeout
      return [];
    } on FormatException {
      // JSON parse error
      return [];
    } catch (e) {
      // Any other error - graceful degradation
      // In production, consider logging this
      return [];
    }
  }
}

/// Fake implementation for testing/development.
class FakeGitHubApiDataSource implements GitHubApiDataSource {
  const FakeGitHubApiDataSource();

  @override
  Future<List<String>> getTopRepositories(
    String username, {
    int limit = 5,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Return sample repos
    return [
      'https://github.com/$username/awesome-flutter-app',
      'https://github.com/$username/dart-utilities',
      'https://github.com/$username/open-source-project',
    ].take(limit).toList();
  }
}
