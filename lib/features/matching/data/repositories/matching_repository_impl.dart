import '../../../../core/error/failures.dart';
import '../../domain/entities/match_item.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/matching_repository.dart';
import '../datasources/matching_http_remote_data_source.dart';
import '../datasources/matching_local_data_source.dart';
import '../datasources/matching_remote_data_source.dart';
import '../models/match_item_model.dart';
import '../models/match_request_model.dart';

/// Returns backend results and exposes caching only as an explicit operation.
/// API failures must reach the caller rather than masquerading as empty results.
class MatchingRepositoryImpl implements MatchingRepository {
  MatchingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final MatchingRemoteDataSource remoteDataSource;
  final MatchingLocalDataSource localDataSource;
  String? _promptVersion;

  @override
  String? get promptVersion => _promptVersion;

  @override
  Future<List<MatchItem>> getRankedMatches(
    UserProfile profile, {
    String? prompt,
    Set<String>? tags,
  }) async {
    try {
      final request = MatchRequestModel.fromProfile(
        profile,
        prompt: prompt,
        tags: tags,
      );
      final response = await remoteDataSource.getMatches(request);
      final sorted = List<MatchItem>.from(response.matches)
        ..sort((a, b) {
          final byScore = b.score.compareTo(a.score);
          return byScore != 0 ? byScore : a.projectId.compareTo(b.projectId);
        });
      _promptVersion = response.promptVersion;
      return List<MatchItem>.unmodifiable(sorted);
    } on MatchingApiException catch (error) {
      throw switch (error.statusCode) {
        400 => ValidationFailure(error.message),
        401 => AuthFailure(error.message),
        403 => PermissionFailure(error.message),
        0 => NetworkFailure(error.message),
        _ => UnexpectedFailure(error.message),
      };
    } on Failure {
      rethrow;
    } catch (_) {
      throw const UnexpectedFailure(
        'Could not load matches. Please try again.',
      );
    }
  }

  @override
  Future<List<MatchItem>> getCachedMatches(String uid) {
    return localDataSource.getCachedMatches(uid);
  }

  @override
  Future<void> cacheMatches(String uid, List<MatchItem> matches) {
    return localDataSource.cacheMatches(
      uid,
      matches.map(MatchItemModel.fromEntity).toList(),
    );
  }

  @override
  void dispose() => remoteDataSource.close();
}
