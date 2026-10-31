import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileParams {
  const UpdateProfileParams({required this.bio, required this.skills});

  final String bio;
  final List<String> skills;
}

class UpdateProfile extends UseCase<Profile, UpdateProfileParams> {
  UpdateProfile(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Result<Profile>> call(UpdateProfileParams params) {
    return _repository.updateProfile(bio: params.bio, skills: params.skills);
  }
}
