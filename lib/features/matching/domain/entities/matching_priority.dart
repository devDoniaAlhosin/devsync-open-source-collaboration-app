enum MatchingPriority {
  skills(
    label: 'Skills',
    promptTemplate: 'Prioritize projects matching my declared skills.',
  ),
  beginnerFriendly(
    label: 'Interests',
    promptTemplate:
        'Prioritize projects related to my interests and prefer beginner-friendly, well-documented contribution opportunities.',
  ),
  recentActivity(
    label: 'Activity',
    promptTemplate:
        'Prioritize projects with recent GitHub activity where that information is available.',
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
