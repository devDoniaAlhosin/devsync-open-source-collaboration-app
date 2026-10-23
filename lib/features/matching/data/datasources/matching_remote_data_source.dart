import '../models/match_response_model.dart';
import '../models/match_request_model.dart';
import '../models/match_item_model.dart';

/// Calls the matching Cloud Function and returns parsed results.
///
/// Implementation will use `FirebaseFunctions.httpsCallable` once
/// Firebase is wired in. Until then a `MockMatchingRemoteDataSource`
/// returns sample data so the feed screen can be built in parallel.
abstract class MatchingRemoteDataSource {
  /// Send [request] to the Cloud Function and return the parsed response.
  Future<MatchResponseModel> getMatches(MatchRequestModel request);
}

/// Placeholder implementation that returns sample JSON matches.
///
/// Swap this for the real Cloud Function data source once Firebase
/// Cloud Functions are configured.
class MockMatchingRemoteDataSource implements MatchingRemoteDataSource {
  @override
  Future<MatchResponseModel> getMatches(MatchRequestModel request) async {
    // Simulate network delay (target: ≤ 5 s for 95%, NFR-01).
    await Future<void>.delayed(const Duration(milliseconds: 800));

    return MatchResponseModel(
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
}
