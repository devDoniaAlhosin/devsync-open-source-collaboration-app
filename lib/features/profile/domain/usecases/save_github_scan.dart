import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class SaveGithubScanParams {
  const SaveGithubScanParams({
    required this.githubUsername,
    required this.repos,
    required this.commits,
    required this.languages,
  });

  final String githubUsername;
  final int repos;
  final int commits;
  final List<LanguageShare> languages;
}

class SaveGithubScan extends UseCase<Profile, SaveGithubScanParams> {
  SaveGithubScan(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Result<Profile>> call(SaveGithubScanParams params) {
    return _repository.saveGithubScan(
      githubUsername: params.githubUsername,
      repos: params.repos,
      commits: params.commits,
      languages: params.languages,
    );
  }
}
