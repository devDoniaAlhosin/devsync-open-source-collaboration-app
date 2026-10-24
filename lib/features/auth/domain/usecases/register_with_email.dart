import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmail implements UseCase<void, RegisterWithEmailParams> {
  const RegisterWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(RegisterWithEmailParams params) {
    return _repository.registerWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

class RegisterWithEmailParams {
  const RegisterWithEmailParams({
    required this.email,
    required this.password,
    this.displayName,
  });

  final String email;
  final String password;
  final String? displayName;
}
