enum RequestStatus { isNew, pending, accepted, declined }

enum RequestType { sent, received }

class RequestItem {
  const RequestItem({
    this.id = '',
    this.projectId = '',
    this.senderId,
    this.ownerId,
    required this.initials,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.type,
    this.message,
    this.displayName = 'Contributor',
    this.targetName = '',
    this.matchPercent = 0,
    this.matchSummary = '',
    this.repositoryCount = 0,
    this.commitCount = 0,
    this.languageCount = 0,
    this.skills = const [],
    this.createdAt,
    this.respondedAt,
  });

  /// Unique Firestore document ID.
  final String id;

  /// Related project document ID.
  final String projectId;

  /// Firebase Auth UID of the contributor.
  final String? senderId;

  /// Firebase Auth UID of the project owner.
  final String? ownerId;

  // Existing presentation fields.
  final String initials;
  final String title;
  final String subtitle;
  final RequestStatus status;
  final RequestType type;
  final String? message;
  final String displayName;
  final String targetName;
  final int matchPercent;
  final String matchSummary;
  final int repositoryCount;
  final int commitCount;
  final int languageCount;
  final List<String> skills;

  /// Request creation and response timestamps.
  final DateTime? createdAt;
  final DateTime? respondedAt;

  bool get isPending =>
      status == RequestStatus.pending || status == RequestStatus.isNew;

  bool get isReceived => type == RequestType.received;

  bool get isSent => type == RequestType.sent;

  bool get canRespond => isReceived && isPending && ownerId != null;

  RequestItem copyWith({
    String? id,
    String? projectId,
    String? senderId,
    String? ownerId,
    String? initials,
    String? title,
    String? subtitle,
    RequestStatus? status,
    RequestType? type,
    String? message,
    String? displayName,
    String? targetName,
    int? matchPercent,
    String? matchSummary,
    int? repositoryCount,
    int? commitCount,
    int? languageCount,
    List<String>? skills,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return RequestItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      senderId: senderId ?? this.senderId,
      ownerId: ownerId ?? this.ownerId,
      initials: initials ?? this.initials,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      type: type ?? this.type,
      message: message ?? this.message,
      displayName: displayName ?? this.displayName,
      targetName: targetName ?? this.targetName,
      matchPercent: matchPercent ?? this.matchPercent,
      matchSummary: matchSummary ?? this.matchSummary,
      repositoryCount: repositoryCount ?? this.repositoryCount,
      commitCount: commitCount ?? this.commitCount,
      languageCount: languageCount ?? this.languageCount,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
