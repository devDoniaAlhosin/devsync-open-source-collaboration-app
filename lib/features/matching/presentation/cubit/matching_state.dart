part of 'matching_cubit.dart';

enum MatchingViewMode { studio, deck }

enum MatchingStatus { initial, loading, success, empty, failure }

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

final class MatchingState extends Equatable {
  const MatchingState({
    this.status = MatchingStatus.initial,
    this.isLoading = false,
    this.isGenerating = false,
    this.isSaving = false,
    this.isLoadingAnalytics = false,
    this.errorMessage,
    this.analyticsErrorMessage,
    this.actionErrorMessage,
    this.failure,
    this.matches = const [],
    this.preferences = MatchingPreferences.defaultPreferences,
    this.viewMode = MatchingViewMode.studio,
    this.currentDeckIndex = 0,
    this.actionHistory = const [],
    this.feedback = const [],
    this.analytics = MatchingAnalytics.empty,
    this.promptVersion,
    required this.profile,
  });

  final MatchingStatus status;
  final bool isLoading;
  final bool isGenerating;
  final bool isSaving;
  final bool isLoadingAnalytics;
  final String? errorMessage;
  final String? analyticsErrorMessage;
  final String? actionErrorMessage;
  final MatchingFailure? failure;
  final List<MatchItem> matches;
  final MatchingPreferences preferences;
  final MatchingViewMode viewMode;
  final int currentDeckIndex;
  final List<MatchActionRecord> actionHistory;
  final List<FeedbackRecord> feedback;
  final MatchingAnalytics analytics;
  final String? promptVersion;
  final UserProfile profile;

  bool get isInitial => status == MatchingStatus.initial;
  bool get isLoadingState => status == MatchingStatus.loading;
  bool get isSuccess => status == MatchingStatus.success;
  bool get isEmptyState => status == MatchingStatus.empty;
  bool get isFailure => status == MatchingStatus.failure;
  String? get profileName => profile.displayName;
  bool get canUndo => actionHistory.isNotEmpty;
  bool get hasMatches => matches.isNotEmpty;
  bool get hasError => failure != null || errorMessage != null;

  MatchItem? get currentDeckMatch {
    if (matches.isEmpty || currentDeckIndex >= matches.length) return null;
    return matches[currentDeckIndex];
  }

  List<MatchItem> get nextDeckMatches {
    if (matches.isEmpty) return const [];
    return List.unmodifiable(matches.skip(currentDeckIndex + 1).take(2));
  }

  MatchingState copyWith({
    MatchingStatus? status,
    bool? isLoading,
    bool? isGenerating,
    bool? isSaving,
    bool? isLoadingAnalytics,
    String? errorMessage,
    bool clearError = false,
    String? analyticsErrorMessage,
    bool clearAnalyticsError = false,
    String? actionErrorMessage,
    bool clearActionError = false,
    MatchingFailure? failure,
    bool clearFailure = false,
    List<MatchItem>? matches,
    MatchingPreferences? preferences,
    MatchingViewMode? viewMode,
    int? currentDeckIndex,
    List<MatchActionRecord>? actionHistory,
    List<FeedbackRecord>? feedback,
    MatchingAnalytics? analytics,
    String? promptVersion,
    bool clearPromptVersion = false,
    UserProfile? profile,
  }) {
    return MatchingState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      isSaving: isSaving ?? this.isSaving,
      isLoadingAnalytics: isLoadingAnalytics ?? this.isLoadingAnalytics,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      analyticsErrorMessage: clearAnalyticsError
          ? null
          : (analyticsErrorMessage ?? this.analyticsErrorMessage),
      actionErrorMessage: clearActionError
          ? null
          : (actionErrorMessage ?? this.actionErrorMessage),
      failure: clearFailure ? null : (failure ?? this.failure),
      matches: matches ?? this.matches,
      preferences: preferences ?? this.preferences,
      viewMode: viewMode ?? this.viewMode,
      currentDeckIndex: currentDeckIndex ?? this.currentDeckIndex,
      actionHistory: actionHistory ?? this.actionHistory,
      feedback: feedback ?? this.feedback,
      analytics: analytics ?? this.analytics,
      promptVersion: clearPromptVersion
          ? null
          : (promptVersion ?? this.promptVersion),
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isLoading,
    isGenerating,
    isSaving,
    isLoadingAnalytics,
    errorMessage,
    analyticsErrorMessage,
    actionErrorMessage,
    failure,
    matches,
    preferences,
    viewMode,
    currentDeckIndex,
    actionHistory,
    feedback,
    analytics,
    promptVersion,
    profile,
  ];
}
