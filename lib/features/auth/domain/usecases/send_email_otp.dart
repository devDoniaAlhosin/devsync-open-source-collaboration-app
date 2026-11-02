import '../../../../core/result/result.dart';
import '../repositories/auth_repository.dart';

class SendEmailOtpParams {
  const SendEmailOtpParams({
    required this.email,
    this.purpose = 'verify',
  });

  final String email;
  final String purpose;
}

class SendEmailOtp {
  const SendEmailOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(SendEmailOtpParams params) {
    return _repository.sendEmailOtp(params.email, purpose: params.purpose);
  }
}
