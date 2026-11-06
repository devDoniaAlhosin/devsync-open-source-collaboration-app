import 'matching_priority.dart';

/// User's match preferences and AI prompt tuning parameters.
class MatchingPreferences {
  const MatchingPreferences({
    required this.prompt,
    this.selectedTags = const {},
    this.priority = MatchingPriority.skills,
  });

  final String prompt;
  final Set<String> selectedTags;
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

  static const MatchingPreferences defaultPreferences = MatchingPreferences(
    prompt: '',
    selectedTags: {},
    priority: MatchingPriority.skills,
  );
}
