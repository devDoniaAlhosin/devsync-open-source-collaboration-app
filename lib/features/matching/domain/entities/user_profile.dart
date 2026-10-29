/// The structured developer profile sent to the matching Cloud Function.
///
/// Built from GitHub data + declared skills. This is a domain-level value
/// object — serialization lives in the data layer.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.declaredSkills,
    required this.githubLanguages,
    required this.publicRepoCount,
    required this.totalContributions,
    this.bio,
    this.topRepositories = const [],
  });

  /// Firebase Auth UID.
  final String uid;

  /// Skills the user explicitly listed on their profile.
  final List<String> declaredSkills;

  /// Languages extracted from public GitHub repos (e.g. {"Dart": 45, "Python": 30}).
  final Map<String, int> githubLanguages;

  /// Number of public repositories.
  final int publicRepoCount;

  /// Total contributions in the last year.
  final int totalContributions;

  /// Short bio from the profile screen.
  final String? bio;

  /// Names of top repositories (by stars or recent activity).
  final List<String> topRepositories;
}
