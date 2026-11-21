import '../../../../core/result/result.dart';
import '../../../matching/domain/entities/github_scan_result.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Result<Profile>> getProfile();

  Future<Result<Profile>> updateProfile({
    required String bio,
    required List<String> skills,
  });

  Future<Result<GithubScanResult>> scanGithub(String username);

  Future<Result<Profile>> saveGithubScan({
    required String githubUsername,
    required int repos,
    required int commits,
    required List<LanguageShare> languages,
    String? bioSuggestion,
    List<List<int>> activity = const [],
  });
}
