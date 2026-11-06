import 'dart:io';

import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/match_item.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/matching_failures.dart';
import '../../domain/repositories/matching_repository.dart';
import '../datasources/matching_cache_data_source.dart';
import '../datasources/matching_http_remote_data_source.dart';
import '../datasources/matching_local_data_source.dart';
import '../datasources/matching_remote_data_source.dart';
import '../models/match_item_model.dart';
import '../models/match_request_model.dart';
import '../utils/profile_hash.dart';

/// Coordinates remote matching API requests and local caching.
///
/// Implements cache-first strategy:
/// 1. Check cache validity (profile hash + TTL)
/// 2. Return cached results if valid
/// 3. Fetch from API if cache miss/expired
/// 4. Update cache with new results
class MatchingRepositoryImpl implements MatchingRepository {
  MatchingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.cacheDataSource,
  });

  final MatchingRemoteDataSource remoteDataSource;
  final MatchingLocalDataSource localDataSource;
  final MatchingCacheDataSource cacheDataSource;
  String? _promptVersion;

  @override
  String? get promptVersion => _promptVersion;

  @override
  Future<List<MatchItem>> getRankedMatches(
    UserProfile profile, {
    String? prompt,
    Set<String>? tags,
    Profile? userProfile,
  }) async {
    // Generate profile hash for cache validation
    final profileHash = userProfile != null
        ? ProfileHashGenerator.fromProfile(userProfile)
        : _generateHashFromUserProfile(profile);

    try {
      // Try cache first
      final isCacheValid = await cacheDataSource.isCacheValid(profileHash);
      if (isCacheValid) {
        final cachedMatches = await cacheDataSource.getCachedMatches();
        if (cachedMatches != null && cachedMatches.isNotEmpty) {
          return List<MatchItem>.unmodifiable(cachedMatches);
        }
      }

      // Cache miss or expired - fetch from API
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

      final sorted = List<MatchItemModel>.from(response.matches)
        ..sort((a, b) {
          final byScore = b.score.compareTo(a.score);
          return byScore != 0 ? byScore : a.projectId.compareTo(b.projectId);
        });

      _promptVersion = response.promptVersion;

      // Update cache with new results
      await cacheDataSource.cacheMatches(sorted, profileHash: profileHash);

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

  /// Generate hash from UserProfile when Profile entity is not available.
  ///
  /// Falls back to basic hash generation using UserProfile fields.
  String _generateHashFromUserProfile(UserProfile profile) {
    return ProfileHashGenerator.fromProfile(
      Profile(
        name: '',
        githubUrl: '',
        completion: 0,
        bio: '',
        repos: profile.publicRepoCount,
        commits: profile.totalContributions,
        languageCount: profile.githubLanguages.length,
        activity: [],
        languages: [],
        skills: profile.declaredSkills,
        topRepositories: profile.topRepositories,
      ),
    );
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
