class UserProfile {
  const UserProfile({
    required this.uid,
    required this.declaredSkills,
    required this.githubLanguages,
    required this.publicRepoCount,
    required this.totalContributions,
    this.bio,
    this.topRepositories = const [],
    this.displayName,
    this.githubUrl,
  });

  final String uid;
  final List<String> declaredSkills;
  final Map<String, int> githubLanguages;
  final int publicRepoCount;
  final int totalContributions;
  final String? bio;
  final List<String> topRepositories;
  final String? displayName;
  final String? githubUrl;

  static const empty = UserProfile(
    uid: '',
    declaredSkills: [],
    githubLanguages: {},
    publicRepoCount: 0,
    totalContributions: 0,
  );
}
