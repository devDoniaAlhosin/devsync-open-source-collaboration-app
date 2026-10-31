class Project {
  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.githubUrl,
    required this.techStack,
    required this.requiredContributors,
    required this.viewsCount,
    required this.requestsCount,
    required this.matchPercentage,
    required this.isOwner,
  });

  final String id;
  final String title;
  final String description;
  final String githubUrl;
  final List<String> techStack;
  final int requiredContributors;
  final int viewsCount;
  final int requestsCount;
  final int matchPercentage;
  final bool isOwner;

  String get initials => initialsFromTitle(title);

  String get cleanGithubUrl {
    return githubUrl
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceFirst(RegExp(r'^www\.'), '')
        .replaceFirst(RegExp(r'/$'), '');
  }

  String get contributorsLabel {
    return requiredContributors == 1
        ? 'Needs 1 contributor'
        : 'Needs $requiredContributors contributors';
  }

  bool get isBeginnerFriendly =>
      requiredContributors <= 2 ||
      description.toLowerCase().contains('beginner');

  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? githubUrl,
    List<String>? techStack,
    int? requiredContributors,
    int? viewsCount,
    int? requestsCount,
    int? matchPercentage,
    bool? isOwner,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      githubUrl: githubUrl ?? this.githubUrl,
      techStack: techStack ?? this.techStack,
      requiredContributors: requiredContributors ?? this.requiredContributors,
      viewsCount: viewsCount ?? this.viewsCount,
      requestsCount: requestsCount ?? this.requestsCount,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      isOwner: isOwner ?? this.isOwner,
    );
  }
}

/// Initials helper shared by project UI and other features (matching, requests).
String initialsFromTitle(String title) {
  final words = title
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((word) => word.isNotEmpty)
      .toList();

  if (words.length >= 2) {
    final last = words.last;
    if (last.length == 2) {
      return last.toUpperCase();
    }
    return '${words.first[0]}${last[0]}'.toUpperCase();
  }
  if (words.length == 1 && words.first.length >= 2) {
    return words.first.substring(0, 2).toUpperCase();
  }
  return title.isEmpty ? 'DS' : title.substring(0, 1).toUpperCase();
}
