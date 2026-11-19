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
    MatchingCacheDataSource? cacheDataSource,
  }) : cacheDataSource = cacheDataSource ?? const NoOpMatchingCacheDataSource();

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
    List<CandidateProject>? candidateProjects,
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
        projects: candidateProjects,
        prompt: prompt,
        tags: tags,
      );
      final response = await remoteDataSource.getMatches(request);

      // If candidate projects were provided, drop any results whose projectId was not sent
      final allowedIds = candidateProjects != null
          ? candidateProjects.map((p) => p.projectId).toSet()
          : null;

      // Filter out non-matching candidates (score <= 0 or missing all required skills or unknown id)
      final relevantMatches = response.matches.where((match) {
        if (allowedIds != null && !allowedIds.contains(match.projectId)) {
          return false;
        }
        if (match.score <= 0) return false;
        final normalizedReason = match.reason.trim().toLowerCase();
        if (normalizedReason.startsWith('missing all required skills')) {
          return false;
        }
        if (normalizedReason.startsWith('no skill overlap') ||
            normalizedReason.startsWith('no matching skills')) {
          return false;
        }
        return true;
      }).toList();

      // Check if we got any matching results
      if (relevantMatches.isEmpty) {
        throw const NoMatchesFailure();
      }

      final sorted = List<MatchItemModel>.from(relevantMatches)
        ..sort((a, b) {
          final byScore = b.score.compareTo(a.score);
          return byScore != 0 ? byScore : a.projectId.compareTo(b.projectId);
        });

      final finalMatches = response.fallback
          ? sorted
                .map(
                  (m) => m.isFallback
                      ? m
                      : MatchItemModel(
                          projectId: m.projectId,
                          projectName: m.projectName,
                          description: m.description,
                          githubUrl: m.githubUrl,
                          neededSkills: m.neededSkills,
                          score: m.score,
                          reason: m.reason,
                          maintainerId: m.maintainerId,
                          isFallback: true,
                        ),
                )
                .toList()
          : sorted;

      _promptVersion = response.promptVersion;

      // Update cache with new results
      await cacheDataSource.cacheMatches(
        finalMatches,
        profileHash: profileHash,
      );

      return List<MatchItem>.unmodifiable(finalMatches);
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
