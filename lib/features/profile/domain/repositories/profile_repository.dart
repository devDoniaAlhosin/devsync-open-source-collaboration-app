import '../../../../core/result/result.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Result<Profile>> getProfile();

  Future<Result<Profile>> updateProfile({
    required String bio,
    required List<String> skills,
  });

  Future<Result<Profile>> saveGithubScan({
    required String githubUsername,
    required int repos,
    required int commits,
    required List<LanguageShare> languages,
  });
}
