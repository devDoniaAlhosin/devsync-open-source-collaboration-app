import '../../../../core/result/result.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Result<Profile>> getProfile();

  Future<Result<Profile>> updateProfile({
    required String bio,
    required List<String> skills,
  });
}
