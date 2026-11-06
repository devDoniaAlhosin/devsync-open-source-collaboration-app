import 'dart:io';

import '../../domain/entities/match_item.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/matching_failures.dart';
import '../../domain/repositories/matching_repository.dart';
import '../datasources/matching_http_remote_data_source.dart';
import '../datasources/matching_local_data_source.dart';
import '../datasources/matching_remote_data_source.dart';
import '../models/match_item_model.dart';
import '../models/match_request_model.dart';

/// Coordinates remote matching API requests and local caching.
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

      // Check if we got any matches
      if (response.matches.isEmpty) {
        throw const NoMatchesFailure();
      }

      final sorted = List<MatchItem>.from(response.matches)
        ..sort((a, b) {
          final byScore = b.score.compareTo(a.score);
          return byScore != 0 ? byScore : a.projectId.compareTo(b.projectId);
        });
      _promptVersion = response.promptVersion;
      return List<MatchItem>.unmodifiable(sorted);
    } on MatchingApiException catch (error) {
      // Map HTTP errors to domain failures
      throw switch (error.statusCode) {
        401 || 403 => const AuthFailure(),
        429 => const RateLimitFailure(),
        >= 500 => const ServerFailure(),
        400 => ValidationFailure(error.message),
        0 => const NetworkFailure(), // No status code = network error
        _ => UnknownFailure(error.message),
      };
    } on SocketException {
      throw const NetworkFailure();
    } on MatchingFailure {
      rethrow;
    } catch (error) {
      throw UnknownFailure(error.toString());
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
