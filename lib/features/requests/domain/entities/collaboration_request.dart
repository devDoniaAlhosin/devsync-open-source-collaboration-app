enum RequestStatus { isNew, pending, accepted, declined }

enum RequestType { sent, received }

class RequestItem {
  const RequestItem({
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
  });

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
}
