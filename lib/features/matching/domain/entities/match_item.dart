/// A single project match returned by the AI matching engine.
///
/// This is a pure domain entity — no JSON, no Firebase, no framework imports.
/// Data-layer models convert to/from this type.
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

  /// Firestore document ID of the project.
  final String projectId;

  /// Display name (e.g. "flutter/packages").
  final String projectName;

  /// Short project description.
  final String description;

  /// Link to the GitHub repository.
  final String githubUrl;

  /// Skills the project is looking for.
  final List<String> neededSkills;

  /// AI-generated fit score (0–100).
  final double score;

  /// One-sentence explanation of why this project is a match.
  final String reason;

  /// UID of the project maintainer (for collaboration requests).
  final String? maintainerId;

  /// `true` when this result came from the skills-based fallback
  /// instead of the LLM.
  final bool isFallback;

  @override
  String toString() => 'MatchItem($projectName, score=$score)';
}
