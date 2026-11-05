import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/auth_token_provider.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_http_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_request_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'matching_http_remote_data_source_test.mocks.dart';

@GenerateMocks([AuthTokenProvider])
void main() {
  group('MatchingHttpRemoteDataSource', () {
    late MockAuthTokenProvider mockAuthTokenProvider;
    late MatchingHttpRemoteDataSource dataSource;

    const testToken = 'test-firebase-id-token';
    const baseUrl = 'http://localhost:3000';

    final testRequest = MatchRequestModel(
      uid: 'user123',
      declaredSkills: ['flutter', 'dart'],
      githubLanguages: {'Dart': 100},
      publicRepoCount: 5,
      totalContributions: 50,
      bio: 'Test bio',
      topRepositories: [],
    );

    setUp(() {
      mockAuthTokenProvider = MockAuthTokenProvider();
      dataSource = MatchingHttpRemoteDataSource(
        baseUrl: baseUrl,
        authTokenProvider: mockAuthTokenProvider,
      );
    });

    group('Authentication', () {
      test('throws MatchingApiException when auth token is null', () async {
        when(mockAuthTokenProvider.getIdToken()).thenAnswer((_) async => null);

        expect(
          () => dataSource.getMatches(testRequest),
          throwsA(
            isA<MatchingApiException>().having(
              (e) => e.message,
              'message',
              contains('Authentication required'),
            ),
          ),
        );
      });

      test('requests auth token before making API call', () async {
        when(
          mockAuthTokenProvider.getIdToken(),
        ).thenAnswer((_) async => testToken);

        // This will fail to reach the server, but we're just testing that
        // the auth token is requested first
        try {
          await dataSource.getMatches(testRequest);
        } catch (_) {
          // Expected to fail - server not actually running
        }

        verify(mockAuthTokenProvider.getIdToken()).called(1);
      });
    });

    group('Request Model Contract', () {
      test('MatchRequestModel serializes all required fields', () {
        final request = MatchRequestModel(
          uid: 'test-uid-123',
          declaredSkills: ['Flutter', 'Dart', 'Firebase'],
          githubLanguages: {'Dart': 8500, 'JavaScript': 1500},
          publicRepoCount: 15,
          totalContributions: 250,
          bio: 'Mobile developer with 5 years experience',
          topRepositories: ['awesome-app', 'cool-lib'],
        );

        final json = request.toJson();

        expect(json['uid'], 'test-uid-123');
        expect(json['declaredSkills'], ['Flutter', 'Dart', 'Firebase']);
        expect(json['githubLanguages'], {'Dart': 8500, 'JavaScript': 1500});
        expect(json['publicRepoCount'], 15);
        expect(json['totalContributions'], 250);
        expect(json['bio'], 'Mobile developer with 5 years experience');
        expect(json['topRepositories'], ['awesome-app', 'cool-lib']);
      });

      test('MatchRequestModel handles optional bio field', () {
        final request = MatchRequestModel(
          uid: 'test-uid',
          declaredSkills: ['Dart'],
          githubLanguages: {},
          publicRepoCount: 0,
          totalContributions: 0,
          topRepositories: [],
        );

        final json = request.toJson();

        // bio is excluded from JSON when null (not included as key)
        expect(json.containsKey('bio'), false);
      });

      test('MatchRequestModel handles empty collections', () {
        final request = MatchRequestModel(
          uid: 'test-uid',
          declaredSkills: [],
          githubLanguages: {},
          publicRepoCount: 0,
          totalContributions: 0,
          topRepositories: [],
        );

        final json = request.toJson();

        expect(json['declaredSkills'], isEmpty);
        expect(json['githubLanguages'], isEmpty);
        expect(json['topRepositories'], isEmpty);
      });
    });

    group('Response Model Contract', () {
      test('MatchResponseModel parses empty matches array', () {
        final json = {
          'matches': <Map<String, dynamic>>[],
          'promptVersion': '1.0',
        };

        final response = MatchResponseModel.fromJson(json);

        expect(response.matches, isEmpty);
        expect(response.promptVersion, '1.0');
      });

      test('MatchResponseModel parses match with all required fields', () {
        final json = {
          'matches': [
            {
              'projectId': 'proj456',
              'projectName': 'Test Project',
              'description': 'A Flutter testing project',
              'githubUrl': 'https://github.com/test/project',
              'neededSkills': ['Flutter', 'Dart'],
              'score': 85.5,
              'reason': 'Shared Flutter and Dart skills',
              'maintainerId': 'user123',
              'isFallback': false,
            },
          ],
          'promptVersion': '2.0',
        };

        final response = MatchResponseModel.fromJson(json);

        expect(response.matches.length, 1);
        expect(response.matches[0].projectId, 'proj456');
        expect(response.matches[0].projectName, 'Test Project');
        expect(response.matches[0].score, 85.5);
        expect(response.matches[0].reason, 'Shared Flutter and Dart skills');
        expect(response.matches[0].isFallback, false);
        expect(response.matches[0].neededSkills, ['Flutter', 'Dart']);
        expect(response.promptVersion, '2.0');
      });

      test('MatchResponseModel parses fallback matches', () {
        final json = {
          'matches': [
            {
              'projectId': 'proj789',
              'projectName': 'Fallback Project',
              'description': 'Default project match',
              'githubUrl': 'https://github.com/fallback/project',
              'neededSkills': ['Any'],
              'score': 50.0,
              'reason': 'Deterministic fallback match',
              'isFallback': true,
            },
          ],
          'promptVersion': '1.5',
        };

        final response = MatchResponseModel.fromJson(json);

        expect(response.matches[0].isFallback, true);
      });
    });

    group('Error Handling', () {
      test('MatchingApiException includes status code', () {
        const exception = MatchingApiException('Server error', statusCode: 500);

        expect(exception.message, 'Server error');
        expect(exception.statusCode, 500);
        expect(exception.toString(), 'Server error');
      });

      test('MatchingApiException defaults status code to 0', () {
        const exception = MatchingApiException('Network error');

        expect(exception.statusCode, 0);
      });
    });

    group('Unimplemented Methods', () {
      test('generateMatchesWithPrompt throws UnimplementedError', () {
        expect(
          () => dataSource.generateMatchesWithPrompt(prompt: 'test'),
          throwsUnimplementedError,
        );
      });

      test('getAnalytics throws UnimplementedError', () {
        expect(() => dataSource.getAnalytics(), throwsUnimplementedError);
      });
    });
  });
}
