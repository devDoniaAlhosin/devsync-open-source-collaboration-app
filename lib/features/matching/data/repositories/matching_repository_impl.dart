import '../../domain/entities/match_item.dart';
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
      final sorted = response.matches
        ..sort((a, b) => b.score.compareTo(a.score));

      // Cache for offline / quick re-display.
      await localDataSource.cacheMatches(profile.uid, sorted);

      return sorted;
    } catch (_) {
      // FR-14: skills-based fallback when the model fails or times out.
      // TODO: Implement real skills fallback algorithm.
      final cached = await localDataSource.getCachedMatches(profile.uid);
      if (cached.isNotEmpty) return cached;

      // Return empty — the presentation layer shows DsEmptyState.
      return [];
    }
  }

  @override
  Future<List<MatchItem>> getCachedMatches(String uid) {
    return localDataSource.getCachedMatches(uid);
  }

  @override
  Future<void> cacheMatches(String uid, List<MatchItem> matches) {
    final models = matches
        .map((e) => MatchItemModel.fromEntity(e))
        .toList();
    return localDataSource.cacheMatches(uid, models);
  }
}
