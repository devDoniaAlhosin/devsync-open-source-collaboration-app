import '../../../../core/result/result.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpParams {
  const VerifyOtpParams({
    required this.email,
    required this.code,
    this.purpose = 'verify',
  });

  final String email;
  final String code;
  final String purpose;
}

class VerifyOtp {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(
      email: params.email,
      code: params.code,
      purpose: params.purpose,
    );
  }
}
