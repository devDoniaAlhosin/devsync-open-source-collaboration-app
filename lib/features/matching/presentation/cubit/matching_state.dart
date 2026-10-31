part of 'matching_cubit.dart';

enum MatchingViewMode { studio, deck }

class MatchActionRecord extends Equatable {
  const MatchActionRecord({
    required this.index,
    required this.action,
    required this.match,
  });

  final int index;
  final MatchSwipeAction action;
  final MatchItem match;

  @override
  List<Object?> get props => [index, action, match];
}

final class MatchingState extends Equatable {
  const MatchingState({
    this.isLoading = false,
    this.isGenerating = false,
    this.errorMessage,
    this.matches = const [],
    this.analytics = MatchingAnalytics.demoAnalytics,
    this.preferences = MatchingPreferences.defaultPreferences,
    this.viewMode = MatchingViewMode.studio,
    this.currentDeckIndex = 0,
    this.actionHistory = const [],
    required this.profile,
  });

  final bool isLoading;
  final bool isGenerating;
  final String? errorMessage;
  final List<MatchItem> matches;
  final MatchingAnalytics analytics;
  final MatchingPreferences preferences;
  final MatchingViewMode viewMode;
  final int currentDeckIndex;
  final List<MatchActionRecord> actionHistory;
  final UserProfile profile;

  bool get canUndo => actionHistory.isNotEmpty;

  bool get hasMatches => matches.isNotEmpty;

  MatchItem? get currentDeckMatch {
    if (matches.isEmpty || currentDeckIndex >= matches.length) return null;
    return matches[currentDeckIndex];
  }

  List<MatchItem> get nextDeckMatches {
    if (matches.isEmpty) return const [];
    return matches.skip(currentDeckIndex + 1).take(2).toList();
  }

  MatchingState copyWith({
    bool? isLoading,
    bool? isGenerating,
    String? errorMessage,
    bool clearError = false,
    List<MatchItem>? matches,
    MatchingAnalytics? analytics,
    MatchingPreferences? preferences,
    MatchingViewMode? viewMode,
    int? currentDeckIndex,
    List<MatchActionRecord>? actionHistory,
    UserProfile? profile,
  }) {
    return MatchingState(
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      matches: matches ?? this.matches,
      analytics: analytics ?? this.analytics,
      preferences: preferences ?? this.preferences,
      viewMode: viewMode ?? this.viewMode,
      currentDeckIndex: currentDeckIndex ?? this.currentDeckIndex,
      actionHistory: actionHistory ?? this.actionHistory,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isGenerating,
    errorMessage,
    matches,
    analytics,
    preferences,
    viewMode,
    currentDeckIndex,
    actionHistory,
    profile,
  ];
}
