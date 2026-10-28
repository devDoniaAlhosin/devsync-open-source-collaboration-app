import 'matching_priority.dart';

/// User's match preferences and AI prompt tuning parameters.
class MatchingPreferences {
  const MatchingPreferences({
    required this.prompt,
    this.selectedTags = const {'Flutter UI', 'Testing', 'Firebase'},
    this.priority = MatchingPriority.skills,
  });

  /// The active natural-language prompt describing preferred open-source work.
  final String prompt;

  /// Quick skill / topic tags selected to guide recommendations.
  final Set<String> selectedTags;

  /// Current prioritization signal for AI scoring.
  final MatchingPriority priority;

  MatchingPreferences copyWith({
    String? prompt,
    Set<String>? selectedTags,
    MatchingPriority? priority,
  }) {
    return MatchingPreferences(
      prompt: prompt ?? this.prompt,
      selectedTags: selectedTags ?? this.selectedTags,
      priority: priority ?? this.priority,
    );
  }

  /// Default baseline preferences for new users.
  static const MatchingPreferences defaultPreferences = MatchingPreferences(
    prompt:
        'Find beginner-friendly Flutter or Firebase projects where I can help with UI, animations, testing, and documentation. Prefer active maintainers.',
    selectedTags: {'Flutter UI', 'Testing', 'Firebase'},
    priority: MatchingPriority.skills,
  );
}
