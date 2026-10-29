import '../../domain/entities/user_profile.dart';

/// Serializable request payload sent to the matching Cloud Function.
class MatchRequestModel {
  const MatchRequestModel({
    required this.uid,
    required this.declaredSkills,
    required this.githubLanguages,
    required this.publicRepoCount,
    required this.totalContributions,
    this.bio,
    this.topRepositories = const [],
  });

  final String uid;
  final List<String> declaredSkills;
  final Map<String, int> githubLanguages;
  final int publicRepoCount;
  final int totalContributions;
  final String? bio;
  final List<String> topRepositories;

  /// Build from the domain [UserProfile].
  factory MatchRequestModel.fromProfile(UserProfile profile) {
    return MatchRequestModel(
      uid: profile.uid,
      declaredSkills: profile.declaredSkills,
      githubLanguages: profile.githubLanguages,
      publicRepoCount: profile.publicRepoCount,
      totalContributions: profile.totalContributions,
      bio: profile.bio,
      topRepositories: profile.topRepositories,
    );
  }

  /// Serialize to the JSON body expected by the Cloud Function.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'declaredSkills': declaredSkills,
      'githubLanguages': githubLanguages,
      'publicRepoCount': publicRepoCount,
      'totalContributions': totalContributions,
      if (bio != null) 'bio': bio,
      'topRepositories': topRepositories,
    };
  }
}
