import 'dart:convert';

import 'package:devsync_open_source_collaboration_app/features/profile/data/datasources/github_profile_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/exceptions/github_profile_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GithubProfileRemoteDataSource', () {
    test('uses GraphQL commit total and README bio when token is present', () async {
      final client = MockClient((request) async {
        if (request.url.path == '/users/octocat') {
          return http.Response(
            jsonEncode({
              'login': 'octocat',
              'public_repos': 2,
              'bio': 'fallback bio',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/users/octocat/repos') {
          return http.Response(
            jsonEncode([
              {'language': 'Dart'},
              {'language': 'Dart'},
              {'language': 'Python'},
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/graphql') {
          return http.Response(
            jsonEncode({
              'data': {
                'user': {
                  'contributionsCollection': {
                    'totalCommitContributions': 128,
                    'contributionCalendar': {
                      'weeks': [
                        {
                          'contributionDays': [
                            for (var i = 0; i < 7; i++)
                              {'contributionCount': i == 0 ? 12 : 0},
                          ],
                        },
                      ],
                    },
                  },
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/repos/octocat/octocat/readme') {
          final markdown = '# Hello\n\nI ship Flutter apps and love open source.';
          return http.Response(
            jsonEncode({
              'encoding': 'base64',
              'content': base64.encode(utf8.encode(markdown)),
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('not found', 404);
      });

      final source = GithubProfileRemoteDataSource(
        client: client,
        token: 'test-token',
      );

      final result = await source.scan('octocat');

      expect(result.username, 'octocat');
      expect(result.publicRepos, 2);
      expect(result.commitsLastYear, 128);
      expect(result.bioSuggestion, contains('Flutter'));
      expect(result.bioSuggestion!.length, lessThanOrEqualTo(140));
      expect(result.languages.first, 'Dart');
      expect(result.activity, isNotEmpty);
    });

    test('REST commit search uses spaces in q and does not return silent zero', () async {
      Uri? commitSearchUri;
      final client = MockClient((request) async {
        if (request.url.path == '/users/octocat') {
          return http.Response(
            jsonEncode({
              'login': 'octocat',
              'public_repos': 1,
              'bio': null,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/users/octocat/repos') {
          return http.Response(
            jsonEncode([
              {'language': 'Go'},
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/search/commits') {
          commitSearchUri = request.url;
          expect(
            request.headers['Accept'],
            'application/vnd.github.cloak-preview+json',
          );
          return http.Response(
            jsonEncode({'total_count': 42}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/repos/octocat/octocat/readme') {
          return http.Response('{}', 404);
        }
        return http.Response('not found', 404);
      });

      // No token → GraphQL skipped, REST search used.
      final source = GithubProfileRemoteDataSource(
        client: client,
        token: '',
      );

      final result = await source.scan('octocat');

      expect(result.commitsLastYear, 42);
      expect(commitSearchUri, isNotNull);
      final q = commitSearchUri!.queryParameters['q']!;
      expect(q.contains('author:octocat'), isTrue);
      expect(q.contains('committer-date:>'), isTrue);
      expect(q.contains('+'), isFalse);
      expect(result.bioSuggestion, isNull);
    });

    test('commit search rate limit throws instead of returning 0', () async {
      final client = MockClient((request) async {
        if (request.url.path == '/users/octocat') {
          return http.Response(
            jsonEncode({'login': 'octocat', 'public_repos': 0}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/users/octocat/repos') {
          return http.Response('[]', 200);
        }
        if (request.url.path == '/search/commits') {
          return http.Response('rate limit', 403);
        }
        if (request.url.path == '/repos/octocat/octocat/readme') {
          return http.Response('{}', 404);
        }
        return http.Response('not found', 404);
      });

      final source = GithubProfileRemoteDataSource(
        client: client,
        token: '',
      );

      expect(
        () => source.scan('octocat'),
        throwsA(isA<GithubProfileException>()),
      );
    });

    test('falls back to GitHub bio when profile README is missing', () async {
      final client = MockClient((request) async {
        if (request.url.path == '/users/octocat') {
          return http.Response(
            jsonEncode({
              'login': 'octocat',
              'public_repos': 0,
              'bio': 'Builds tools for developers.',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/users/octocat/repos') {
          return http.Response('[]', 200);
        }
        if (request.url.path == '/graphql') {
          return http.Response(
            jsonEncode({
              'data': {
                'user': {
                  'contributionsCollection': {
                    'totalCommitContributions': 3,
                    'contributionCalendar': {'weeks': []},
                  },
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/repos/octocat/octocat/readme') {
          return http.Response('{}', 404);
        }
        return http.Response('not found', 404);
      });

      final source = GithubProfileRemoteDataSource(
        client: client,
        token: 'tok',
      );

      final result = await source.scan('octocat');
      expect(result.bioSuggestion, 'Builds tools for developers.');
      expect(result.commitsLastYear, 3);
    });
  });
}
