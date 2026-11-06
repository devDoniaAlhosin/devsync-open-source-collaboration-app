import '../../domain/entities/user_profile.dart';

/// Profile and preferences sent to the matching API. The backend fetches projects.
class MatchRequestModel {
  const MatchRequestModel({
    required this.uid,
    required this.declaredSkills,
    required this.githubLanguages,
    required this.publicRepoCount,
    required this.totalContributions,
    this.bio,
    this.topRepositories = const [],
    this.prompt,
    this.tags,
  });

  final String uid;
  final List<String> declaredSkills;
  final Map<String, int> githubLanguages;
  final int publicRepoCount;
  final int totalContributions;
  final String? bio;
  final List<String> topRepositories;
  final String? prompt;
  final Set<String>? tags;

  /// Build from the domain [UserProfile].
  factory MatchRequestModel.fromProfile(
    UserProfile profile, {
    String? prompt,
    Set<String>? tags,
  }) {
    return MatchRequestModel(
      uid: profile.uid,
      declaredSkills: profile.declaredSkills,
      githubLanguages: profile.githubLanguages,
      publicRepoCount: profile.publicRepoCount,
      totalContributions: profile.totalContributions,
      bio: profile.bio,
      topRepositories: profile.topRepositories,
      prompt: prompt,
      tags: tags,
    );
  }

  /// Preferences never change the user's declared skills.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'declaredSkills': declaredSkills,
      'githubLanguages': githubLanguages,
      'publicRepoCount': publicRepoCount,
      'totalContributions': totalContributions,
      if (bio != null) 'bio': bio,
      'topRepositories': topRepositories,
      if (prompt != null) 'prompt': prompt,
      if (tags != null) 'tags': tags!.toList(),
    };
  }
}
