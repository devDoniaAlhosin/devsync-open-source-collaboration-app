import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SendEmailVerification implements UseCase<void, NoParams> {
  const SendEmailVerification(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.sendEmailVerification();
  }
}
