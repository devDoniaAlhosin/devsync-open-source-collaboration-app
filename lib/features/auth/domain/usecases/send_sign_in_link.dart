import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SendSignInLink implements UseCase<void, String> {
  const SendSignInLink(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(String email) {
    return _repository.sendSignInLinkToEmail(email);
  }
}
