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
    this.ownerId = '',
    this.ownerName = '',
    this.createdAt,
    this.hasPendingRequest = false,
  });

  final String id;
  final String title;
  final String description;
  final String githubUrl;
  final List<String> techStack;
  final int requiredContributors;
  final int viewsCount;
  final int requestsCount;

  /// Cached AI match score. Computed by `feature/matching` / the DevSync API;
  /// this module only reads and presents it.
  final int matchPercentage;
  final bool isOwner;

  /// Firebase uid of the maintainer. Empty for legacy/demo records.
  final String ownerId;

  /// Denormalized maintainer name so Discover can render without an extra read.
  final String ownerName;
  final DateTime? createdAt;

  /// True when the signed-in user already has a pending request for this
  /// project (viewer-relative, resolved by the data layer).
  final bool hasPendingRequest;

  String get initials => initialsFromTitle(title);

  bool isOwnedBy(String? uid) =>
      uid != null && uid.isNotEmpty && ownerId == uid;

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
    String? ownerId,
    String? ownerName,
    DateTime? createdAt,
    bool? hasPendingRequest,
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
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt ?? this.createdAt,
      hasPendingRequest: hasPendingRequest ?? this.hasPendingRequest,
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
