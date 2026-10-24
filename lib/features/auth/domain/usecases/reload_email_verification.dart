import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ReloadEmailVerification implements UseCase<bool, NoParams> {
  const ReloadEmailVerification(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<bool>> call(NoParams params) {
    return _repository.reloadAndIsEmailVerified();
  }
}
