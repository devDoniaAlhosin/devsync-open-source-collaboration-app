import '../../../../core/result/result.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailOtpParams {
  const SignInWithEmailOtpParams({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;
}

class SignInWithEmailOtp {
  const SignInWithEmailOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(SignInWithEmailOtpParams params) {
    return _repository.signInWithEmailOtp(
      email: params.email,
      code: params.code,
    );
  }
}
