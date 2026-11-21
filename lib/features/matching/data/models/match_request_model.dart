import '../../domain/entities/user_profile.dart';

class CandidateProject {
  const CandidateProject({
    required this.projectId,
    required this.projectName,
    required this.description,
    required this.githubUrl,
    required this.neededSkills,
    this.maintainerId,
  });

  final String projectId;
  final String projectName;
  final String description;
  final String githubUrl;
  final List<String> neededSkills;
  final String? maintainerId;

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'projectName': projectName,
    'description': description,
    'githubUrl': githubUrl,
    'neededSkills': neededSkills,
    if (maintainerId != null) 'maintainerId': maintainerId,
  };

  factory CandidateProject.fromJson(Map<String, dynamic> json) =>
      CandidateProject(
        projectId: json['projectId'] as String? ?? '',
        projectName: json['projectName'] as String? ?? '',
        description: json['description'] as String? ?? '',
        githubUrl: json['githubUrl'] as String? ?? '',
        neededSkills:
            (json['neededSkills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        maintainerId: json['maintainerId'] as String?,
      );
}

class MatchRequestModel {
  const MatchRequestModel({
    required this.uid,
    required this.declaredSkills,
    required this.githubLanguages,
    required this.publicRepoCount,
    required this.totalContributions,
    this.bio,
    this.topRepositories = const [],
    this.projects,
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
  final List<CandidateProject>? projects;
  final String? prompt;
  final Set<String>? tags;

  factory MatchRequestModel.fromProfile(
    UserProfile profile, {
    List<CandidateProject>? projects,
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
      projects: projects,
      prompt: prompt,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'declaredSkills': declaredSkills,
      'githubLanguages': githubLanguages,
      'publicRepoCount': publicRepoCount,
      'totalContributions': totalContributions,
      if (bio != null) 'bio': bio,
      'topRepositories': topRepositories,
      if (projects != null)
        'projects': projects!.map((p) => p.toJson()).toList(),
      if (prompt != null) 'prompt': prompt,
      if (tags != null) 'tags': tags!.toList(),
    };
  }
}
