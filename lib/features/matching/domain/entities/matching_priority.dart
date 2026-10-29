/// Priority options for tuning matching recommendations.
enum MatchingPriority {
  skills(
    label: 'Skills',
    promptTemplate:
        'Prioritize projects matching my Flutter, Firebase, UI, animation, and testing skills. Prefer beginner-friendly issues and active maintainers.',
  ),
  beginnerFriendly(
    label: 'Beginner-friendly',
    promptTemplate:
        'Prioritize beginner-friendly, well-documented Flutter or Firebase issues with clear steps and responsive maintainers.',
  ),
  recentActivity(
    label: 'Recent activity',
    promptTemplate:
        'Prioritize Flutter and Firebase repositories with recent commits, active maintainers, and open issues that match my skills.',
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
