part of 'matching_cubit.dart';

enum MatchingViewMode { studio, deck }

class MatchActionRecord extends Equatable {
  const MatchActionRecord({
    required this.index,
    required this.action,
    required this.match,
    required this.removesSavedMatchOnUndo,
  });

  final int index;
  final MatchSwipeAction action;
  final MatchItem match;
  final bool removesSavedMatchOnUndo;

  @override
  List<Object?> get props => [index, action, match, removesSavedMatchOnUndo];
}

/// State for [MatchingCubit].
final class MatchingState extends Equatable {
  const MatchingState({
    this.isLoading = false,
    this.isGenerating = false,
    this.isSaving = false,
    this.errorMessage,
    this.actionErrorMessage,
    this.matches = const [],
    this.preferences = MatchingPreferences.defaultPreferences,
    this.viewMode = MatchingViewMode.studio,
    this.currentDeckIndex = 0,
    this.actionHistory = const [],
    this.promptVersion,
    required this.profile,
  });

  final bool isLoading;
  final bool isGenerating;
  final bool isSaving;
  final String? errorMessage;
  final String? actionErrorMessage;
  final List<MatchItem> matches;
  final MatchingPreferences preferences;
  final MatchingViewMode viewMode;
  final int currentDeckIndex;
  final List<MatchActionRecord> actionHistory;
  final String? promptVersion;
  final UserProfile profile;

  String? get profileName => profile.displayName;
  bool get canUndo => actionHistory.isNotEmpty;
  bool get hasMatches => matches.isNotEmpty;

  MatchItem? get currentDeckMatch {
    if (matches.isEmpty || currentDeckIndex >= matches.length) return null;
    return matches[currentDeckIndex];
  }

  List<MatchItem> get nextDeckMatches {
    if (matches.isEmpty) return const [];
    return List.unmodifiable(matches.skip(currentDeckIndex + 1).take(2));
  }

  MatchingState copyWith({
    bool? isLoading,
    bool? isGenerating,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    String? actionErrorMessage,
    bool clearActionError = false,
    List<MatchItem>? matches,
    MatchingPreferences? preferences,
    MatchingViewMode? viewMode,
    int? currentDeckIndex,
    List<MatchActionRecord>? actionHistory,
    String? promptVersion,
    bool clearPromptVersion = false,
    UserProfile? profile,
  }) {
    return MatchingState(
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionErrorMessage: clearActionError
          ? null
          : (actionErrorMessage ?? this.actionErrorMessage),
      matches: matches ?? this.matches,
      preferences: preferences ?? this.preferences,
      viewMode: viewMode ?? this.viewMode,
      currentDeckIndex: currentDeckIndex ?? this.currentDeckIndex,
      actionHistory: actionHistory ?? this.actionHistory,
      promptVersion: clearPromptVersion
          ? null
          : (promptVersion ?? this.promptVersion),
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isGenerating,
    isSaving,
    errorMessage,
    actionErrorMessage,
    matches,
    preferences,
    viewMode,
    currentDeckIndex,
    actionHistory,
    promptVersion,
    profile,
  ];
}
