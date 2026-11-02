import '../../../../core/result/result.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordWithOtpParams {
  const ResetPasswordWithOtpParams({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  final String email;
  final String code;
  final String newPassword;
}

class ResetPasswordWithOtp {
  const ResetPasswordWithOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(ResetPasswordWithOtpParams params) {
    return _repository.resetPasswordWithOtp(
      email: params.email,
      code: params.code,
      newPassword: params.newPassword,
    );
  }
}
