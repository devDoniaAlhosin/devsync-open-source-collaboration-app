import '../../../../core/result/result.dart';
import '../repositories/auth_repository.dart';

class ConfirmEmailWithOtpParams {
  const ConfirmEmailWithOtpParams({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;
}

class ConfirmEmailWithOtp {
  const ConfirmEmailWithOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(ConfirmEmailWithOtpParams params) {
    return _repository.confirmEmailWithOtp(
      email: params.email,
      code: params.code,
    );
  }
}
