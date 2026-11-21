import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MatchResponseModel', () {
    test('parses valid response with matches and promptVersion', () {
      final json = {
        'promptVersion': 'v2.0',
        'fallback': false,
        'matches': [
          {
            'projectId': 'proj-1',
            'projectName': 'DevSync',
            'description': 'Collab app',
            'githubUrl': 'https://github.com/devsync/app',
            'neededSkills': ['Flutter', 'Dart'],
            'score': 88.5,
            'reason': 'Great Dart skills',
            'maintainerId': 'user-1',
            'isFallback': false,
          },
        ],
      };

      final response = MatchResponseModel.fromJson(json);

      expect(response.promptVersion, 'v2.0');
      expect(response.fallback, isFalse);
      expect(response.matches.length, 1);
      final match = response.matches.first;
      expect(match.projectId, 'proj-1');
      expect(match.projectName, 'DevSync');
      expect(match.description, 'Collab app');
      expect(match.githubUrl, 'https://github.com/devsync/app');
      expect(match.neededSkills, ['Flutter', 'Dart']);
      expect(match.score, 88.5);
      expect(match.reason, 'Great Dart skills');
      expect(match.maintainerId, 'user-1');
      expect(match.isFallback, isFalse);
    });

    test(
      'parses fallback flag at top level (both fallback and isFallback)',
      () {
        final json1 = {
          'promptVersion': 'v1',
          'fallback': true,
          'matches': <dynamic>[],
        };
        final res1 = MatchResponseModel.fromJson(json1);
        expect(res1.fallback, isTrue);

        final json2 = {
          'promptVersion': 'v1',
          'isFallback': true,
          'matches': <dynamic>[],
        };
        final res2 = MatchResponseModel.fromJson(json2);
        expect(res2.fallback, isTrue);
      },
    );

    test('throws FormatException on missing or non-string promptVersion', () {
      expect(
        () => MatchResponseModel.fromJson({'matches': []}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => MatchResponseModel.fromJson({'promptVersion': '', 'matches': []}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () =>
            MatchResponseModel.fromJson({'promptVersion': 123, 'matches': []}),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException on non-list matches', () {
      expect(
        () => MatchResponseModel.fromJson({
          'promptVersion': 'v1',
          'matches': 'invalid',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException on non-map match items', () {
      expect(
        () => MatchResponseModel.fromJson({
          'promptVersion': 'v1',
          'matches': ['string-item'],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException on duplicate project IDs in response', () {
      final json = {
        'promptVersion': 'v1',
        'matches': [
          {
            'projectId': 'dup-1',
            'projectName': 'A',
            'description': '',
            'githubUrl': '',
            'neededSkills': <String>[],
            'score': 50,
            'reason': '',
          },
          {
            'projectId': 'dup-1',
            'projectName': 'B',
            'description': '',
            'githubUrl': '',
            'neededSkills': <String>[],
            'score': 60,
            'reason': '',
          },
        ],
      };
      expect(
        () => MatchResponseModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException on bad payload fields inside matches', () {
      // Invalid score (out of 0-100 range)
      expect(
        () => MatchResponseModel.fromJson({
          'promptVersion': 'v1',
          'matches': [
            {
              'projectId': 'p1',
              'projectName': 'A',
              'description': '',
              'githubUrl': '',
              'neededSkills': <String>[],
              'score': 150,
              'reason': '',
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );

      // Missing projectName
      expect(
        () => MatchResponseModel.fromJson({
          'promptVersion': 'v1',
          'matches': [
            {
              'projectId': 'p1',
              'description': '',
              'githubUrl': '',
              'neededSkills': <String>[],
              'score': 80,
              'reason': '',
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );

      // Invalid neededSkills
      expect(
        () => MatchResponseModel.fromJson({
          'promptVersion': 'v1',
          'matches': [
            {
              'projectId': 'p1',
              'projectName': 'A',
              'description': '',
              'githubUrl': '',
              'neededSkills': [1, 2, 3],
              'score': 80,
              'reason': '',
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
