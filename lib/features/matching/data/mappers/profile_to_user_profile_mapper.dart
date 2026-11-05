import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/user_profile.dart';

/// Maps the profile feature's [Profile] entity to matching's [UserProfile].
///
/// This bridges the two features, converting UI-focused profile data into
/// the structure expected by the matching backend API.
class ProfileToUserProfileMapper {
  /// Convert [Profile] to [UserProfile] for matching API requests.
  ///
  /// Requires [uid] from Firebase Auth since Profile doesn't store it.
  static UserProfile map(Profile profile, String uid) {
    // Convert LanguageShare list to Map<String, int> (language name → percentage)
    final githubLanguages = <String, int>{};
    for (final lang in profile.languages) {
      githubLanguages[lang.name] = lang.percent;
    }

    return UserProfile(
      uid: uid,
      declaredSkills: profile.skills,
      githubLanguages: githubLanguages,
      publicRepoCount: profile.repos,
      totalContributions: profile.commits,
      bio: profile.bio.isEmpty ? null : profile.bio,
      topRepositories: const [], // TODO: Add top repositories from GitHub API
    );
  }
}
