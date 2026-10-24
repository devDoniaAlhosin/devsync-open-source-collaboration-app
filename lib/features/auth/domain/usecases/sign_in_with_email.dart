import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmail implements UseCase<void, SignInWithEmailParams> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(SignInWithEmailParams params) {
    return _repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithEmailParams {
  const SignInWithEmailParams({required this.email, required this.password});

  final String email;
  final String password;
}
