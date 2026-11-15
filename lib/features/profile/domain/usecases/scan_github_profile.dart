import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../matching/domain/entities/github_scan_result.dart';
import '../repositories/profile_repository.dart';

class ScanGithubProfileParams {
  const ScanGithubProfileParams(this.username);

  final String username;
}

class ScanGithubProfile
    implements UseCase<GithubScanResult, ScanGithubProfileParams> {
  ScanGithubProfile(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Result<GithubScanResult>> call(ScanGithubProfileParams params) {
    return _repository.scanGithub(params.username);
  }
}
