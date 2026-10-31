import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/match_item.dart';
import '../../domain/entities/matching_analytics.dart';
import '../../domain/entities/matching_preferences.dart';
import '../../domain/entities/matching_priority.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/matching_repository.dart';
import '../../domain/usecases/generate_matches_usecase.dart';
import '../../domain/usecases/get_matching_analytics_usecase.dart';
import '../../domain/usecases/get_ranked_matches_usecase.dart';
import '../liked_matches_store.dart';
import '../widgets/draggable_match_card.dart';

part 'matching_state.dart';

/// Presentation state for the matching feature (Cubit replaces ChangeNotifier).
class MatchingCubit extends Cubit<MatchingState> {
  static const defaultProfile = UserProfile(
    uid: 'demo-user',
    declaredSkills: ['Flutter', 'Dart', 'Firebase'],
    githubLanguages: {'Dart': 60, 'Python': 20, 'JavaScript': 10},
    publicRepoCount: 12,
    totalContributions: 340,
    bio: 'Mobile developer interested in open source.',
  );

  MatchingCubit({
    required MatchingRepository repository,
    UserProfile? profile,
  }) : _getRankedMatchesUseCase = GetRankedMatchesUseCase(repository),
       _generateMatchesUseCase = GenerateMatchesUseCase(repository),
       _getMatchingAnalyticsUseCase = GetMatchingAnalyticsUseCase(repository),
       super(
         MatchingState(profile: profile ?? defaultProfile),
       );

  final GetRankedMatchesUseCase _getRankedMatchesUseCase;
  final GenerateMatchesUseCase _generateMatchesUseCase;
  final GetMatchingAnalyticsUseCase _getMatchingAnalyticsUseCase;

  Future<void> generateMatches() async {
    if (state.isGenerating) return;
    emit(state.copyWith(isGenerating: true, clearError: true));

    try {
      final results = await _generateMatchesUseCase(
        prompt: state.preferences.prompt,
        tags: state.preferences.selectedTags,
      );

      emit(
        state.copyWith(
          matches: results,
          currentDeckIndex: 0,
          actionHistory: const [],
          isGenerating: false,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isGenerating: false,
          errorMessage: 'Failed to generate recommendations.',
        ),
      );
    }
  }

  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final results = await _getRankedMatchesUseCase(state.profile);
      final analyticsData = await _getMatchingAnalyticsUseCase();

      emit(
        state.copyWith(
          matches: results,
          analytics: analyticsData,
          currentDeckIndex: 0,
          actionHistory: const [],
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load matches. Please try again.',
        ),
      );
    }
  }

  void performDeckAction(MatchItem match, MatchSwipeAction action) {
    if (state.currentDeckIndex >= state.matches.length ||
        state.matches[state.currentDeckIndex].projectId != match.projectId) {
      return;
    }

    final history = List<MatchActionRecord>.from(state.actionHistory)
      ..add(
        MatchActionRecord(
          index: state.currentDeckIndex,
          action: action,
          match: match,
        ),
      );

    if (action == MatchSwipeAction.request) {
      LikedMatchesStore.instance.add(match);
    }

    emit(
      state.copyWith(
        actionHistory: history,
        currentDeckIndex: state.currentDeckIndex + 1,
      ),
    );
  }

  void refinePromptWithPriority(MatchingPriority priority) {
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(
          priority: priority,
          prompt: priority.promptTemplate,
        ),
      ),
    );
  }

  void setPriority(MatchingPriority priority) {
    if (state.preferences.priority == priority) return;
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(priority: priority),
      ),
    );
  }

  void setViewMode(MatchingViewMode mode) {
    if (state.viewMode == mode) return;
    emit(state.copyWith(viewMode: mode));
  }

  void toggleTag(String tag) {
    final updated = Set<String>.from(state.preferences.selectedTags);
    if (updated.contains(tag)) {
      updated.remove(tag);
    } else {
      updated.add(tag);
    }
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(selectedTags: updated),
      ),
    );
  }

  void undoLastDeckAction() {
    if (state.actionHistory.isEmpty) return;
    final history = List<MatchActionRecord>.from(state.actionHistory);
    final last = history.removeLast();
    emit(
      state.copyWith(
        actionHistory: history,
        currentDeckIndex: last.index,
      ),
    );
  }

  void updatePrompt(String text) {
    if (state.preferences.prompt == text) return;
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(prompt: text),
      ),
    );
  }
}
