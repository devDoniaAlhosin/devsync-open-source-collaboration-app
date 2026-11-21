import 'dart:convert';
import 'dart:io';

import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/auth_token_provider.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_http_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _request = MatchRequestModel(
  uid: 'signed-in-user',
  declaredSkills: ['Dart'],
  githubLanguages: {'Dart': 120},
  publicRepoCount: 3,
  totalContributions: 8,
  topRepositories: ['owner/repository'],
  prompt: 'Prefer documentation',
  tags: {'Testing'},
);

class _Tokens implements AuthTokenProvider {
  String? token = 'initial-token';
  String? refreshed = 'refreshed-token';
  Object? error;
  final List<bool> calls = [];

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    calls.add(forceRefresh);
    if (error != null) throw error!;
    return forceRefresh ? refreshed : token;
  }
}

void main() {
  late HttpServer server;
  late _Tokens tokens;
  late MatchingHttpRemoteDataSource source;
  late Future<void> Function(HttpRequest) handle;
  var requests = 0;

  Future<void> reply(HttpRequest request, int status, Object body) async {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    await request.response.close();
  }

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    tokens = _Tokens();
    requests = 0;
    handle = (request) =>
        reply(request, 200, {'matches': [], 'promptVersion': 'v1'});
    server.listen((request) async {
      requests++;
      await handle(request);
    });
    source = MatchingHttpRemoteDataSource(
      baseUrl: 'http://127.0.0.1:${server.port}/',
      authTokenProvider: tokens,
    );
  });

  tearDown(() async {
    source.close();
    await server.close(force: true);
  });

  test('posts actual profile and preferences with bearer token', () async {
    Map<String, dynamic>? payload;
    handle = (request) async {
      expect(request.method, 'POST');
      expect(request.uri.path, '/matches/generate');
      expect(
        request.headers.value(HttpHeaders.authorizationHeader),
        'Bearer initial-token',
      );
      expect(request.headers.contentType?.mimeType, 'application/json');
      payload =
          jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>;
      await reply(request, 200, {'matches': [], 'promptVersion': 'v1'});
    };
    final response = await source.getMatches(_request);
    expect(response.matches, isEmpty);
    expect(response.promptVersion, 'v1');
    expect(payload, _request.toJson());
    expect(payload!.containsKey('projects'), isFalse);
    expect(payload!['declaredSkills'], ['Dart']);
    expect(payload!['tags'], ['Testing']);
    expect(tokens.calls, [false]);
  });

  for (final token in <String?>[null, '']) {
    test('missing token $token prevents any HTTP request', () async {
      tokens.token = token;
      await expectLater(
        source.getMatches(_request),
        throwsA(
          isA<MatchingApiException>().having(
            (e) => e.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(requests, 0);
    });
  }

  test('refreshes unauthorized token once and preserves payload', () async {
    final seenTokens = <String?>[];
    handle = (request) async {
      seenTokens.add(request.headers.value(HttpHeaders.authorizationHeader));
      expect(
        jsonDecode(await utf8.decoder.bind(request).join()),
        _request.toJson(),
      );
      await reply(request, requests == 1 ? 401 : 200, {
        'matches': [],
        'promptVersion': 'v1',
      });
    };
    await source.getMatches(_request);
    expect(tokens.calls, [false, true]);
    expect(seenTokens, ['Bearer initial-token', 'Bearer refreshed-token']);
  });

  test('rejected refreshed token does not retry a third time', () async {
    handle = (request) => reply(request, 401, {'error': 'private detail'});
    await expectLater(
      source.getMatches(_request),
      throwsA(
        isA<MatchingApiException>().having((e) => e.statusCode, 'status', 401),
      ),
    );
    expect(requests, 2);
    expect(tokens.calls, [false, true]);
  });

  test('missing refreshed token stops before sending a retry', () async {
    tokens.refreshed = null;
    handle = (request) => reply(request, 401, {});
    await expectLater(
      source.getMatches(_request),
      throwsA(
        isA<MatchingApiException>().having((e) => e.statusCode, 'status', 401),
      ),
    );
    expect(requests, 1);
  });

  for (final status in [400, 403, 429, 500, 503]) {
    test('maps $status safely without retry', () async {
      handle = (request) =>
          reply(request, status, {'error': 'SECRET token stack trace'});
      await expectLater(
        source.getMatches(_request),
        throwsA(
          isA<MatchingApiException>()
              .having((e) => e.statusCode, 'status', status)
              .having(
                (e) => e.message,
                'safe message',
                isNot(contains('SECRET')),
              ),
        ),
      );
      expect(requests, 1);
      expect(tokens.calls, [false]);
    });
  }

  for (final body in [
    'not-json',
    '[]',
    '{}',
    '{"matches":{},"promptVersion":"v1"}',
  ]) {
    test('rejects malformed response $body', () async {
      handle = (request) async {
        request.response.write(body);
        await request.response.close();
      };
      await expectLater(
        source.getMatches(_request),
        throwsA(
          isA<MatchingApiException>().having(
            (e) => e.statusCode,
            'status',
            502,
          ),
        ),
      );
    });
  }

  test('auth provider errors are sanitized', () async {
    tokens.error = const AuthTokenException('SECRET internal auth details');
    await expectLater(
      source.getMatches(_request),
      throwsA(
        isA<MatchingApiException>()
            .having((e) => e.statusCode, 'status', 401)
            .having(
              (e) => e.message,
              'safe message',
              isNot(contains('SECRET')),
            ),
      ),
    );
    expect(requests, 0);
  });

  test('a stalled HTTP response times out', () async {
    source.close();
    source = MatchingHttpRemoteDataSource(
      baseUrl: 'http://127.0.0.1:${server.port}',
      authTokenProvider: tokens,
      requestTimeout: const Duration(milliseconds: 50),
    );
    handle = (_) async {};
    await expectLater(
      source.getMatches(_request),
      throwsA(
        isA<MatchingApiException>().having(
          (e) => e.message,
          'message',
          contains('too long'),
        ),
      ),
    );
  });

  test('connection refusal returns safe network failure', () async {
    await server.close(force: true);
    await expectLater(
      source.getMatches(_request),
      throwsA(
        isA<MatchingApiException>()
            .having((e) => e.statusCode, 'status', 0)
            .having((e) => e.message, 'message', contains('connection')),
      ),
    );
  });
}
