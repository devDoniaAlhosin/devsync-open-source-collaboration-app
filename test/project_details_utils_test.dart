import 'package:devsync_open_source_collaboration_app/features/matching/presentation/utils/project_details_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('skill coverage normalizes case and whitespace', () {
    final coverage = skillCoverageFor(
      neededSkills: const [' Dart ', 'FIREBASE', 'Flutter'],
      currentUserSkills: const ['dart', ' firebase '],
    );

    expect(coverage, closeTo(66.67, .01));
  });

  test('project presentation helpers handle incomplete values', () {
    expect(projectInitials('flutter-oss/charts'), 'fc');
    expect(repositoryHost('not a valid URL'), 'not a valid URL');
    expect(fitLabelForScore(92), 'Strong fit');
  });
}
