import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetEmail implements UseCase<void, String> {
  const SendPasswordResetEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(String email) {
    return _repository.sendPasswordResetEmail(email);
  }
}
