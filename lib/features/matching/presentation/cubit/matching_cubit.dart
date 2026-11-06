import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/liked_matches_local_data_source.dart';
import '../../domain/entities/match_item.dart';
import '../../domain/entities/matching_preferences.dart';
import '../../domain/entities/matching_priority.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/matching_profile_repository.dart';
import '../../domain/repositories/matching_repository.dart';
import '../../domain/usecases/get_ranked_matches_usecase.dart';
import '../widgets/draggable_match_card.dart';

part 'matching_state.dart';

/// State coordinator for real matching inputs, backend results, and saved cards.
class MatchingCubit extends Cubit<MatchingState> {
  MatchingCubit({
    required MatchingRepository repository,
    required LikedMatchesLocalDataSource likedMatchesDataSource,
    MatchingProfileRepository? profileRepository,
    UserProfile? profile,
  }) : _repository = repository,
       _getRankedMatchesUseCase = GetRankedMatchesUseCase(repository),
       _likedMatchesDataSource = likedMatchesDataSource,
       _profileRepository = profileRepository,
       super(MatchingState(profile: profile ?? UserProfile.empty));

  final MatchingRepository _repository;
  final GetRankedMatchesUseCase _getRankedMatchesUseCase;
  final LikedMatchesLocalDataSource _likedMatchesDataSource;
  final MatchingProfileRepository? _profileRepository;

  Future<void> loadInitialData() => _loadMatches(isGenerating: false);

  Future<void> generateMatches() => _loadMatches(isGenerating: true);

  Future<void> _loadMatches({required bool isGenerating}) async {
    if (state.isLoading || state.isGenerating || state.isSaving) return;
    emit(
      state.copyWith(
        isLoading: !isGenerating,
        isGenerating: isGenerating,
        clearError: true,
      ),
    );

    final profile = await _resolveProfile();
    if (profile == null) {
      emit(
        state.copyWith(
          isLoading: false,
          isGenerating: false,
          errorMessage:
              state.actionErrorMessage ??
              'Could not load your matching profile. Please try again.',
          clearActionError: true,
        ),
      );
      return;
    }

    final prompt = state.preferences.prompt.trim();
    if (prompt.length > 1000) {
      emit(
        state.copyWith(
          profile: profile,
          isLoading: false,
          isGenerating: false,
          errorMessage: 'Keep your preference under 1,000 characters.',
        ),
      );
      return;
    }

    try {
      final results = await _getRankedMatchesUseCase(
        profile,
        prompt: prompt.isEmpty ? null : prompt,
        tags: state.preferences.selectedTags.isEmpty
            ? null
            : state.preferences.selectedTags,
      );
      emit(
        state.copyWith(
          profile: profile,
          matches: results,
          promptVersion: _repository.promptVersion,
          currentDeckIndex: 0,
          actionHistory: const [],
          isLoading: false,
          isGenerating: false,
          clearError: true,
          clearActionError: true,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          profile: profile,
          isLoading: false,
          isGenerating: false,
          errorMessage: failure.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          profile: profile,
          isLoading: false,
          isGenerating: false,
          errorMessage: 'Could not load matches. Please try again.',
        ),
      );
    }
  }

  Future<UserProfile?> _resolveProfile() async {
    final profileRepository = _profileRepository;
    if (profileRepository == null) {
      if (state.profile.uid.isNotEmpty) return state.profile;
      emit(
        state.copyWith(actionErrorMessage: 'Please sign in to find matches.'),
      );
      return null;
    }

    UserProfile? profile;
    String? error;
    final result = await profileRepository.getProfile();
    result.fold(
      (failure) => error = failure.message,
      (value) => profile = value,
    );
    if (profile == null) {
      emit(state.copyWith(actionErrorMessage: error));
    }
    return profile;
  }

  /// Saves the actual signed-in account's declared skills.
  Future<bool> saveDeclaredSkills(List<String> skills) async {
    final profileRepository = _profileRepository;
    if (profileRepository == null || state.isSaving) return false;
    emit(state.copyWith(isSaving: true, clearActionError: true));

    UserProfile? profile;
    String? error;
    final result = await profileRepository.updateDeclaredSkills(skills);
    result.fold(
      (failure) => error = failure.message,
      (value) => profile = value,
    );
    if (profile == null) {
      emit(
        state.copyWith(
          isSaving: false,
          actionErrorMessage:
              error ?? 'Could not save your skills. Please try again.',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(profile: profile, isSaving: false, clearActionError: true),
    );
    await loadInitialData();
    return true;
  }

  /// Persists a saved match before advancing the deck.
  Future<bool> performDeckAction(
    MatchItem match,
    MatchSwipeAction action,
  ) async {
    if (state.isSaving ||
        state.currentDeckIndex >= state.matches.length ||
        state.matches[state.currentDeckIndex].projectId != match.projectId) {
      return false;
    }

    var removeSavedMatchOnUndo = false;
    if (action == MatchSwipeAction.request) {
      emit(state.copyWith(isSaving: true, clearActionError: true));
      try {
        final saved = await _likedMatchesDataSource.getLikedMatches();
        final alreadySaved = saved.any(
          (savedMatch) => savedMatch.projectId == match.projectId,
        );
        if (!alreadySaved) {
          await _likedMatchesDataSource.addLikedMatch(match);
          removeSavedMatchOnUndo = true;
        }
      } on LikedMatchesException catch (error) {
        emit(
          state.copyWith(isSaving: false, actionErrorMessage: error.message),
        );
        return false;
      } catch (_) {
        emit(
          state.copyWith(
            isSaving: false,
            actionErrorMessage: 'Could not save this match. Please try again.',
          ),
        );
        return false;
      }
    }

    final history = List<MatchActionRecord>.from(state.actionHistory)
      ..add(
        MatchActionRecord(
          index: state.currentDeckIndex,
          action: action,
          match: match,
          removesSavedMatchOnUndo: removeSavedMatchOnUndo,
        ),
      );
    emit(
      state.copyWith(
        actionHistory: history,
        currentDeckIndex: state.currentDeckIndex + 1,
        isSaving: false,
        clearActionError: true,
      ),
    );
    return true;
  }

  Future<void> undoLastDeckAction() async {
    if (state.isSaving || state.actionHistory.isEmpty) return;
    final last = state.actionHistory.last;
    if (last.removesSavedMatchOnUndo) {
      emit(state.copyWith(isSaving: true, clearActionError: true));
      try {
        await _likedMatchesDataSource.removeLikedMatch(last.match.projectId);
      } on LikedMatchesException catch (error) {
        emit(
          state.copyWith(isSaving: false, actionErrorMessage: error.message),
        );
        return;
      } catch (_) {
        emit(
          state.copyWith(
            isSaving: false,
            actionErrorMessage:
                'Could not undo this saved match. Please try again.',
          ),
        );
        return;
      }
    }
    final history = List<MatchActionRecord>.from(state.actionHistory)
      ..removeLast();
    emit(
      state.copyWith(
        actionHistory: history,
        currentDeckIndex: last.index,
        isSaving: false,
        clearActionError: true,
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
    final normalized = tag.trim();
    if (normalized.isEmpty || normalized.length > 100) return;
    final updated = Set<String>.from(state.preferences.selectedTags);
    if (updated.contains(normalized)) {
      updated.remove(normalized);
    } else if (updated.length < 30) {
      updated.add(normalized);
    }
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(selectedTags: updated),
      ),
    );
  }

  void updatePrompt(String text) {
    if (state.preferences.prompt == text) return;
    emit(state.copyWith(preferences: state.preferences.copyWith(prompt: text)));
  }
}
