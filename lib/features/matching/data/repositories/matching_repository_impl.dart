import 'dart:io';

import '../../../../core/utils/project_details_utils.dart';
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
    final profileHash = userProfile != null
        ? ProfileHashGenerator.fromProfile(userProfile)
        : _generateHashFromUserProfile(profile);

    try {
      final isCacheValid = await cacheDataSource.isCacheValid(profileHash);
      if (isCacheValid) {
        final cachedMatches = await cacheDataSource.getCachedMatches();
        if (cachedMatches != null && cachedMatches.isNotEmpty) {
          return List<MatchItem>.unmodifiable(cachedMatches);
        }
      }

      final request = MatchRequestModel.fromProfile(
        profile,
        projects: candidateProjects,
        prompt: prompt,
        tags: tags,
      );
      final response = await remoteDataSource.getMatches(request);

      final allowedIds = candidateProjects?.map((p) => p.projectId).toSet();

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

      await cacheDataSource.cacheMatches(
        finalMatches,
        profileHash: profileHash,
      );

      return List<MatchItem>.unmodifiable(finalMatches);
    } on MatchingApiException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        throw const AuthFailure();
      }
      if (error.statusCode == 400) {
        final fallback = _computeFallbackMatches(
          profile: profile,
          candidates: candidateProjects,
        );
        if (fallback != null) {
          if (fallback.isEmpty) throw const NoMatchesFailure();
          return List<MatchItem>.unmodifiable(fallback);
        }
        throw ValidationFailure(error.message);
      }

      final fallback = _computeFallbackMatches(
        profile: profile,
        candidates: candidateProjects,
      );
      if (fallback != null) {
        if (fallback.isEmpty) throw const NoMatchesFailure();
        return List<MatchItem>.unmodifiable(fallback);
      }

      throw switch (error.statusCode) {
        429 => const RateLimitFailure(),
        >= 500 => const ServerFailure(),
        0 => const NetworkFailure(),
        _ => UnknownFailure(error.message),
      };
    } on SocketException {
      final fallback = _computeFallbackMatches(
        profile: profile,
        candidates: candidateProjects,
      );
      if (fallback != null) {
        if (fallback.isEmpty) throw const NoMatchesFailure();
        return List<MatchItem>.unmodifiable(fallback);
      }
      throw const NetworkFailure();
    } on MatchingFailure {
      rethrow;
    } catch (error) {
      final fallback = _computeFallbackMatches(
        profile: profile,
        candidates: candidateProjects,
      );
      if (fallback != null) {
        if (fallback.isEmpty) throw const NoMatchesFailure();
        return List<MatchItem>.unmodifiable(fallback);
      }
      throw UnknownFailure(error.toString());
    }
  }

  List<MatchItemModel>? _computeFallbackMatches({
    required UserProfile profile,
    required List<CandidateProject>? candidates,
  }) {
    if (candidates == null) return null;
    final userSkills = normalizedSkills(profile.declaredSkills);
    if (userSkills.isEmpty) return const [];

    final results = <MatchItemModel>[];
    for (final candidate in candidates) {
      if (candidate.maintainerId != null &&
          candidate.maintainerId!.isNotEmpty &&
          candidate.maintainerId == profile.uid) {
        continue;
      }

      final needed = normalizedSkills(candidate.neededSkills);
      if (needed.isEmpty) continue;

      final matchingSkills = candidate.neededSkills
          .where((skill) => userSkills.contains(skill.trim().toLowerCase()))
          .toList();

      if (matchingSkills.isEmpty) continue;

      final score = (matchingSkills.length / needed.length) * 100;
      final reason = matchingSkills.join(', ');

      results.add(
        MatchItemModel(
          projectId: candidate.projectId,
          projectName: candidate.projectName,
          description: candidate.description,
          githubUrl: candidate.githubUrl,
          neededSkills: candidate.neededSkills,
          score: score,
          reason: reason,
          maintainerId: candidate.maintainerId,
          isFallback: true,
          source: MatchSource.fallback,
        ),
      );
    }

    results.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.projectId.compareTo(b.projectId);
    });

    return results;
  }

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
