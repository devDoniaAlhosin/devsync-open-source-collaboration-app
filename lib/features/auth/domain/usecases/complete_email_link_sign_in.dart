import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class CompleteEmailLinkSignIn implements UseCase<void, String> {
  const CompleteEmailLinkSignIn(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(String link) {
    return _repository.completeSignInWithEmailLink(link);
  }
}
