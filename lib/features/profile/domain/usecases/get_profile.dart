import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile extends UseCase<Profile, NoParams> {
  GetProfile(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Result<Profile>> call(NoParams params) => _repository.getProfile();
}
