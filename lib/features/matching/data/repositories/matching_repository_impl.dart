import '../../domain/entities/match_item.dart';
import '../../domain/entities/matching_analytics.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/matching_repository.dart';
import '../datasources/matching_local_data_source.dart';
import '../datasources/matching_remote_data_source.dart';
import '../models/match_item_model.dart';
import '../models/match_request_model.dart';

/// Concrete [MatchingRepository] that coordinates remote (Cloud Function),
/// cache (Firestore / in-memory), and skills-based fallback.
class MatchingRepositoryImpl implements MatchingRepository {
  MatchingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final MatchingRemoteDataSource remoteDataSource;
  final MatchingLocalDataSource localDataSource;

  @override
  Future<List<MatchItem>> getRankedMatches(UserProfile profile) async {
    try {
      final request = MatchRequestModel.fromProfile(profile);
      final response = await remoteDataSource.getMatches(request);

      // Sort descending by score.
      final sorted = List<MatchItem>.from(response.matches)
        ..sort((a, b) => b.score.compareTo(a.score));

      // Cache for offline / quick re-display.
      await localDataSource.cacheMatches(
        profile.uid,
        sorted.map((m) => MatchItemModel.fromEntity(m)).toList(),
      );

      return sorted;
    } catch (_) {
      // Skills-based fallback when the remote service fails or times out.
      final cached = await localDataSource.getCachedMatches(profile.uid);
      if (cached.isNotEmpty) return cached;

      return [];
    }
  }

  @override
  Future<List<MatchItem>> generateMatchesWithPrompt({
    required String prompt,
    Set<String>? tags,
  }) async {
    try {
      final results = await remoteDataSource.generateMatchesWithPrompt(
        prompt: prompt,
        tags: tags,
      );
      final sorted = List<MatchItem>.from(results)
        ..sort((a, b) => b.score.compareTo(a.score));
      return sorted;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<MatchingAnalytics> getMatchingAnalytics() async {
    try {
      final model = await remoteDataSource.getAnalytics();
      return model;
    } catch (_) {
      return MatchingAnalytics.demoAnalytics;
    }
  }

  @override
  Future<List<MatchItem>> getCachedMatches(String uid) {
    return localDataSource.getCachedMatches(uid);
  }

  @override
  Future<void> cacheMatches(String uid, List<MatchItem> matches) {
    final models = matches.map((e) => MatchItemModel.fromEntity(e)).toList();
    return localDataSource.cacheMatches(uid, models);
  }
}
