/// Priority options for tuning matching recommendations.
enum MatchingPriority {
  skills(
    label: 'Skills',
    promptTemplate: 'Prioritize projects matching my declared skills.',
  ),
  beginnerFriendly(
    label: 'Beginner-friendly',
    promptTemplate:
        'Prefer beginner-friendly, well-documented projects with clear contribution steps.',
  ),
  recentActivity(
    label: 'Recent activity',
    promptTemplate:
        'Prefer projects with recent activity where that information is available.',
  );

  const MatchingPriority({required this.label, required this.promptTemplate});

  final String label;
  final String promptTemplate;

  static MatchingPriority fromLabel(String label) {
    return MatchingPriority.values.firstWhere(
      (p) => p.label.toLowerCase() == label.toLowerCase(),
      orElse: () => MatchingPriority.skills,
    );
  }
}
