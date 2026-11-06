/// Represents a ranked project match.
class MatchItem {
  const MatchItem({
    required this.projectId,
    required this.projectName,
    required this.description,
    required this.githubUrl,
    required this.neededSkills,
    required this.score,
    required this.reason,
    this.maintainerId,
    this.isFallback = false,
  });

  final String projectId;
  final String projectName;
  final String description;
  final String githubUrl;
  final List<String> neededSkills;
  final double score;
  final String reason;
  final String? maintainerId;
  final bool isFallback;

  @override
  String toString() => 'MatchItem($projectName, score=$score)';
}
