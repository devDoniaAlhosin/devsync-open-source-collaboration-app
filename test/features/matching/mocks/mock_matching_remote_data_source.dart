import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_item_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_request_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_response_model.dart';

/// Test fixture that returns sample JSON matches and analytics.
///
/// Use this in tests only - production code uses MatchingHttpRemoteDataSource.
class MockMatchingRemoteDataSource implements MatchingRemoteDataSource {
  @override
  Future<MatchResponseModel> getMatches(MatchRequestModel request) async {
    // Simulate network delay (target: ≤ 5 s for 95%, NFR-01).
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return const MatchResponseModel(
      promptVersion: 'v1-sample',
      matches: [
        MatchItemModel(
          projectId: 'sample-1',
          projectName: 'flutter/packages',
          description:
              'A collection of useful packages maintained by the Flutter team.',
          githubUrl: 'https://github.com/flutter/packages',
          neededSkills: ['Flutter', 'Dart', 'CI/CD'],
          score: 92,
          reason:
              'Strong Dart and Flutter activity with CI contributions matching project needs.',
          maintainerId: 'maintainer-1',
        ),
        MatchItemModel(
          projectId: 'sample-2',
          projectName: 'appwrite/appwrite',
          description:
              'Open-source backend server for web, mobile, and Flutter developers.',
          githubUrl: 'https://github.com/appwrite/appwrite',
          neededSkills: ['Flutter', 'REST APIs', 'Docker'],
          score: 78,
          reason:
              'Flutter SDK experience aligns well; REST API skills are a bonus.',
          maintainerId: 'maintainer-2',
        ),
        MatchItemModel(
          projectId: 'sample-3',
          projectName: 'pocketbase/pocketbase',
          description:
              'Open-source backend in a single file — real-time DB, auth, file storage.',
          githubUrl: 'https://github.com/pocketbase/pocketbase',
          neededSkills: ['Go', 'SQLite', 'REST APIs'],
          score: 55,
          reason:
              'REST API overlap; Go is a growth opportunity given your backend interest.',
          maintainerId: 'maintainer-3',
        ),
      ],
    );
  }

  @override
  void close() {}
}
