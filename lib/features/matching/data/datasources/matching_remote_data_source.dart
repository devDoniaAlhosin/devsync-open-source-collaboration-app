import '../../domain/entities/matching_analytics.dart';
import '../models/match_item_model.dart';
import '../models/match_request_model.dart';
import '../models/match_response_model.dart';
import '../models/matching_analytics_model.dart';

/// Calls the matching Cloud Function and returns parsed results.
///
/// Implementation will use `FirebaseFunctions.httpsCallable` once
/// Firebase is wired in. Until then a `MockMatchingRemoteDataSource`
/// returns sample data so the feed and studio screens can be built in parallel.
abstract class MatchingRemoteDataSource {
  /// Send [request] to the Cloud Function and return the parsed response.
  Future<MatchResponseModel> getMatches(MatchRequestModel request);

  /// Generate dynamic matches for the given custom natural-language [prompt] and [tags].
  Future<List<MatchItemModel>> generateMatchesWithPrompt({
    required String prompt,
    Set<String>? tags,
  });

  /// Retrieve recommendation analytics and transparency metrics.
  Future<MatchingAnalyticsModel> getAnalytics();
}

/// Placeholder implementation that returns sample JSON matches and analytics.
///
/// Swap this for the real Cloud Function data source once Firebase
/// Cloud Functions are configured.
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
  Future<List<MatchItemModel>> generateMatchesWithPrompt({
    required String prompt,
    Set<String>? tags,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final lower = prompt.toLowerCase();
    final tagList = tags?.toList() ?? [];

    if (lower.contains('beginner') || lower.contains('documentation')) {
      return const [
        MatchItemModel(
          projectId: 'nova-cli',
          projectName: 'nova-tools/cli',
          description:
              'Beginner-friendly testing and documentation tasks with responsive maintainers.',
          githubUrl: 'https://github.com/nova-tools/cli',
          neededSkills: ['Testing', 'Docs', 'Dart'],
          score: 95,
          reason: 'Clear beginner issues and friendly review mentorship.',
          maintainerId: 'maintainer-nova',
        ),
        MatchItemModel(
          projectId: 'flutter-charts',
          projectName: 'flutter-oss/charts',
          description:
              'Good first issues available for mobile UI styling and animations.',
          githubUrl: 'https://github.com/flutter-oss/charts',
          neededSkills: ['Flutter UI', 'Animations'],
          score: 88,
          reason: 'Well-documented repository with dedicated starter labels.',
          maintainerId: 'maintainer-charts',
        ),
        MatchItemModel(
          projectId: 'firebase-auth-kit',
          projectName: 'firebase-kit/auth',
          description:
              'Community-driven authentication examples and walkthrough guides.',
          githubUrl: 'https://github.com/firebase-kit/auth',
          neededSkills: ['Firebase', 'Flutter UI'],
          score: 82,
          reason: 'Step-by-step contribution guide for first-time authors.',
          maintainerId: 'maintainer-firebase',
        ),
      ];
    }

    return [
      const MatchItemModel(
        projectId: 'flutter-charts',
        projectName: 'flutter-oss/charts',
        description:
            'Strong Flutter UI and animation overlap. Active maintainer seeking chart transitions.',
        githubUrl: 'https://github.com/flutter-oss/charts',
        neededSkills: ['Flutter UI', 'Animations', 'Dart'],
        score: 92,
        reason:
            'Strong Flutter UI and animation overlap. Active maintainer seeking chart transitions.',
        maintainerId: 'maintainer-charts',
      ),
      const MatchItemModel(
        projectId: 'nova-cli',
        projectName: 'nova-tools/cli',
        description:
            'Testing and documentation tasks align with your recent work.',
        githubUrl: 'https://github.com/nova-tools/cli',
        neededSkills: ['Testing', 'Dart', 'CLI'],
        score: 86,
        reason: 'Testing and documentation tasks align with your recent work.',
        maintainerId: 'maintainer-nova',
      ),
      const MatchItemModel(
        projectId: 'firebase-auth-kit',
        projectName: 'firebase-kit/auth',
        description:
            'Auth and Firestore rules are relevant to your GitHub skills.',
        githubUrl: 'https://github.com/firebase-kit/auth',
        neededSkills: ['Firebase', 'Dart', 'Security Rules'],
        score: 81,
        reason: 'Auth and Firestore rules are relevant to your GitHub skills.',
        maintainerId: 'maintainer-firebase',
      ),
      if (tagList.isNotEmpty)
        MatchItemModel(
          projectId: 'custom-tag-match',
          projectName: 'community/devkit',
          description:
              'Matched on active tags: ${tagList.join(", ")}.',
          githubUrl: 'https://github.com/community/devkit',
          neededSkills: tagList,
          score: 79,
          reason: 'Direct skill alignment with selected filter tags.',
          maintainerId: 'maintainer-devkit',
        ),
    ];
  }

  @override
  Future<MatchingAnalyticsModel> getAnalytics() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return MatchingAnalyticsModel.fromEntity(MatchingAnalytics.demoAnalytics);
  }
}
