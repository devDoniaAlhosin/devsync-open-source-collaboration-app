import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SignInWithGitHub implements UseCase<void, NoParams> {
  const SignInWithGitHub(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.signInWithGitHub();
}
