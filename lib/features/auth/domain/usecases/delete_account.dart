import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class DeleteAccountParams {
  const DeleteAccountParams({this.password});

  final String? password;
}

class DeleteAccount implements UseCase<void, DeleteAccountParams> {
  const DeleteAccount(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(DeleteAccountParams params) {
    return _repository.deleteAccount(password: params.password);
  }
}
