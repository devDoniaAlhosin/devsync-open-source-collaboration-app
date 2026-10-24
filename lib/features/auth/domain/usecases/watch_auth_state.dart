import '../../../../core/usecase/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthState implements StreamUseCase<AppUser?, NoParams> {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  @override
  Stream<AppUser?> call(NoParams params) => _repository.watchAuthState();
}
