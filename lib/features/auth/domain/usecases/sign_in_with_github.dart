import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SignInWithGitHubParams {
  const SignInWithGitHubParams({this.onDeviceCode});

  final GitHubDeviceCodeHandler? onDeviceCode;
}

class SignInWithGitHub implements UseCase<void, SignInWithGitHubParams> {
  const SignInWithGitHub(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(SignInWithGitHubParams params) {
    return _repository.signInWithGitHub(onDeviceCode: params.onDeviceCode);
  }
}
