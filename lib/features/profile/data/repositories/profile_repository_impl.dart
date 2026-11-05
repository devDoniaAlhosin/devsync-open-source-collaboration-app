import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/github_api_data_source.dart';
import '../datasources/profile_local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileLocalDataSource localDataSource,
    required GitHubApiDataSource gitHubDataSource,
  }) : _local = localDataSource,
       _gitHub = gitHubDataSource;

  final ProfileLocalDataSource _local;
  final GitHubApiDataSource _gitHub;

  @override
  Future<Result<Profile>> getProfile() async {
    try {
      final profile = await _local.fetchProfile();

      // Fetch top repositories from GitHub if profile has GitHub URL
      if (profile.githubUrl.isNotEmpty && profile.topRepositories.isEmpty) {
        final username = profile.githubUsername;
        final topRepos = await _gitHub.getTopRepositories(username, limit: 5);

        // Update profile with top repositories
        if (topRepos.isNotEmpty) {
          return Success(profile.copyWith(topRepositories: topRepos));
        }
      }

      return Success(profile);
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  @override
  Future<Result<Profile>> updateProfile({
    required String bio,
    required List<String> skills,
  }) async {
    try {
      final trimmed = bio.trim();
      if (trimmed.isEmpty) {
        return const FailureResult(
          ValidationFailure('Bio cannot be empty', field: 'bio'),
        );
      }
      return Success(await _local.saveProfile(bio: trimmed, skills: skills));
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }
}
