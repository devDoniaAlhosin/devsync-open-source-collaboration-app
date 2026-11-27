import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../projects/domain/usecases/get_projects.dart';
import '../../../requests/domain/usecases/get_unavailable_project_ids.dart';
import '../../data/datasources/liked_matches_local_data_source.dart';
import '../../data/datasources/prompt_version_preference.dart';
import '../../data/models/match_request_model.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/feedback_record.dart';
import '../../domain/entities/match_feedback_action.dart';
import '../../domain/entities/match_item.dart';
import '../../domain/entities/matching_analytics.dart';
import '../../domain/entities/matching_preferences.dart';
import '../../domain/entities/matching_priority.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/matching_failures.dart';
import '../../domain/repositories/matching_profile_repository.dart';
import '../../domain/repositories/matching_repository.dart';
import '../../domain/usecases/get_matching_analytics_usecase.dart';
import '../../domain/usecases/get_ranked_matches_usecase.dart';
import '../../domain/usecases/get_user_feedback_usecase.dart';
import '../../domain/usecases/save_match_feedback.dart';
import '../../domain/utils/matching_analytics_aggregator.dart';
import '../widgets/draggable_match_card.dart';

part 'matching_state.dart';

class MatchingCubit extends Cubit<MatchingState> {
  MatchingCubit({
    required MatchingRepository repository,
    required LikedMatchesDataSource likedMatchesDataSource,
    required GetRankedMatchesUseCase getRankedMatchesUseCase,
    MatchingProfileRepository? profileRepository,
    GetProjects? getProjects,
    GetUnavailableProjectIds? getUnavailableProjectIds,
    GetUserFeedbackUseCase? getUserFeedbackUseCase,
    GetMatchingAnalyticsUseCase? getMatchingAnalyticsUseCase,
    SaveMatchFeedback? saveMatchFeedback,
    PromptVersionPreference? promptVersionPreference,
    UserProfile? profile,
  }) : _repository = repository,
       _getRankedMatchesUseCase = getRankedMatchesUseCase,
       _likedMatchesDataSource = likedMatchesDataSource,
       _profileRepository = profileRepository,
       _getProjects = getProjects,
       _getUnavailableProjectIds = getUnavailableProjectIds,
       _getUserFeedbackUseCase = getUserFeedbackUseCase,
       _getMatchingAnalyticsUseCase = getMatchingAnalyticsUseCase,
       _saveMatchFeedback = saveMatchFeedback,
       _promptVersionPreference = promptVersionPreference,
       super(
         MatchingState(
           profile: profile ?? UserProfile.empty,
           promptVersion: promptVersionPreference?.read(),
         ),
       );

  final MatchingRepository _repository;
  final GetRankedMatchesUseCase _getRankedMatchesUseCase;
  final LikedMatchesDataSource _likedMatchesDataSource;
  final MatchingProfileRepository? _profileRepository;
  final GetProjects? _getProjects;
  final GetUnavailableProjectIds? _getUnavailableProjectIds;
  final GetUserFeedbackUseCase? _getUserFeedbackUseCase;
  final GetMatchingAnalyticsUseCase? _getMatchingAnalyticsUseCase;
  final SaveMatchFeedback? _saveMatchFeedback;
  final PromptVersionPreference? _promptVersionPreference;

  bool _lastRequestWasGenerating = false;
  bool _loadInFlight = false;

  bool get isLoadInFlight => _loadInFlight;

  /// Persist and prefer the highest-performing prompt version from quality metrics.
  Future<void> applyPreferredPromptVersion(String version) async {
    final trimmed = version.trim();
    if (trimmed.isEmpty) return;
    await _promptVersionPreference?.write(trimmed);
    if (isClosed) return;
    emit(state.copyWith(promptVersion: trimmed));
  }

  MatchingAnalytics get analytics {
    final projectSkills = <String, List<String>>{};
    for (final match in state.matches) {
      projectSkills[match.projectId] = match.neededSkills;
    }
    for (final action in state.actionHistory) {
      projectSkills[action.match.projectId] = action.match.neededSkills;
    }

    final feedback = state.feedback.isNotEmpty
        ? state.feedback
        : state.actionHistory
              .map(
                (action) => FeedbackRecord(
                  id: 'history_${action.index}',
                  userId: state.profile.uid,
                  projectId: action.match.projectId,
                  action: action.action == MatchSwipeAction.request
                      ? 'like'
                      : 'skip',
                  timestamp: DateTime.now(),
                ),
              )
              .toList();

    return MatchingAnalyticsAggregator.aggregate(
      feedback: feedback,
      declaredSkills: state.profile.declaredSkills,
      projectSkills: projectSkills,
    );
  }

  Future<void> loadAnalytics() async {
    if (state.isLoadingAnalytics) return;

    final getMatchingAnalytics = _getMatchingAnalyticsUseCase;
    if (getMatchingAnalytics == null) {
      final computed = analytics;
      // Sample chart only in debug when the user has no feedback yet.
      final effective = computed.isEmpty
          ? (kDebugMode
                ? MatchingAnalytics.demoAnalytics
                : computed)
          : computed;
      emit(
        state.copyWith(
          analytics: effective,
          isLoadingAnalytics: false,
          clearAnalyticsError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoadingAnalytics: true, clearAnalyticsError: true));
    try {
      final result = await getMatchingAnalytics();
      if (isClosed) return;
      result.fold(
        (_) => emit(
          state.copyWith(
            isLoadingAnalytics: false,
            analyticsErrorMessage:
                'Could not load your insights. Please try again.',
          ),
        ),
        (analytics) => emit(
          state.copyWith(
            isLoadingAnalytics: false,
            analytics: analytics,
            clearAnalyticsError: true,
          ),
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingAnalytics: false,
          analyticsErrorMessage:
              'Could not load your insights. Please try again.',
        ),
      );
    }
  }

  Future<void> loadInitialData() => _loadMatches(isGenerating: false);

  Future<void> generateMatches([MatchingPreferences? preferences]) async {
    if (preferences != null) {
      emit(state.copyWith(preferences: preferences));
    }
    await _loadMatches(isGenerating: true);
  }

  void savePreferences(MatchingPreferences preferences) {
    emit(state.copyWith(preferences: preferences));
  }

  Future<void> retry() async {
    if (_lastRequestWasGenerating) {
      await generateMatches();
    } else {
      await loadInitialData();
    }
  }

  Future<void> _loadMatches({required bool isGenerating}) async {
    // Use an in-flight flag so the initial isLoading:true default still fetches.
    if (_loadInFlight || state.isSaving) return;
    if (isGenerating && state.isGenerating) return;
    if (!isGenerating && state.isGenerating) return;

    _loadInFlight = true;
    _lastRequestWasGenerating = isGenerating;
    emit(
      state.copyWith(
        status: MatchingStatus.loading,
        isLoading: !isGenerating,
        isGenerating: isGenerating,
        clearError: true,
        clearFailure: true,
      ),
    );

    try {
      final profile = await _resolveProfile();
      if (profile == null) {
        emit(
          state.copyWith(
            status: MatchingStatus.failure,
            isLoading: false,
            isGenerating: false,
            failure: const ProfileIncompleteFailure(),
            errorMessage:
                state.actionErrorMessage ??
                'Could not load your matching profile. Please try again.',
            clearActionError: true,
          ),
        );
        return;
      }

      if (profile.declaredSkills.isEmpty) {
        emit(
          state.copyWith(
            status: MatchingStatus.empty,
            profile: profile,
            matches: const [],
            currentDeckIndex: 0,
            isLoading: false,
            isGenerating: false,
            failure: const NoMatchesFailure(),
            clearActionError: true,
          ),
        );
        return;
      }

      final prompt = isGenerating ? state.preferences.prompt.trim() : '';
      if (isGenerating && prompt.length > 1000) {
        emit(
          state.copyWith(
            status: MatchingStatus.failure,
            profile: profile,
            isLoading: false,
            isGenerating: false,
            failure: const ValidationFailure(
              'Keep your preference under 1,000 characters.',
            ),
            errorMessage: 'Keep your preference under 1,000 characters.',
          ),
        );
        return;
      }

      try {
        List<FeedbackRecord> feedback = state.feedback;
        final getUserFeedback = _getUserFeedbackUseCase;
        if (getUserFeedback != null) {
          final feedbackResult = await getUserFeedback();
          feedbackResult.fold((_) {}, (records) {
            feedback = records;
          });
        }

        final excludedIds = <String>{
          for (final record in feedback)
            if (record.projectId.isNotEmpty) record.projectId,
        };

        final getUnavailable = _getUnavailableProjectIds;
        if (getUnavailable != null) {
          final unavailableResult = await getUnavailable(const NoParams());
          unavailableResult.fold((_) {}, excludedIds.addAll);
        }

        List<CandidateProject>? candidateProjects;
        final getProjects = _getProjects;
        if (getProjects != null) {
          final projectsResult = await getProjects(const NoParams());
          projectsResult.fold((_) {}, (projects) {
            candidateProjects = projects
                .where(
                  (p) =>
                      p.id.isNotEmpty &&
                      !excludedIds.contains(p.id) &&
                      p.ownerId != profile.uid,
                )
                .map(
                  (p) => CandidateProject(
                    projectId: p.id,
                    projectName: p.title,
                    description: p.description,
                    githubUrl: p.githubUrl,
                    neededSkills: p.techStack,
                    maintainerId: p.ownerId.isNotEmpty ? p.ownerId : null,
                  ),
                )
                .toList();
          });
        }

        final effectivePrompt = isGenerating && prompt.isNotEmpty
            ? prompt
            : null;
        final effectiveTags =
            isGenerating && state.preferences.selectedTags.isNotEmpty
            ? state.preferences.selectedTags
            : null;

        var results = await _getRankedMatchesUseCase(
          profile,
          prompt: effectivePrompt,
          tags: effectiveTags,
          candidateProjects: candidateProjects,
        );

        // Drop anything the API still returned for owned / requested / reviewed IDs.
        if (excludedIds.isNotEmpty || profile.uid.isNotEmpty) {
          results = results
              .where(
                (match) =>
                    !excludedIds.contains(match.projectId) &&
                    match.maintainerId != profile.uid,
              )
              .toList();
        }

        if (results.isEmpty) {
          emit(
            state.copyWith(
              status: MatchingStatus.empty,
              profile: profile,
              matches: const [],
              feedback: feedback,
              failure: const NoMatchesFailure(),
              promptVersion: _repository.promptVersion,
              currentDeckIndex: 0,
              actionHistory: const [],
              isLoading: false,
              isGenerating: false,
              clearError: true,
              clearActionError: true,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: MatchingStatus.success,
              profile: profile,
              matches: results,
              feedback: feedback,
              promptVersion: _repository.promptVersion,
              currentDeckIndex: 0,
              actionHistory: const [],
              isLoading: false,
              isGenerating: false,
              clearError: true,
              clearFailure: true,
              clearActionError: true,
            ),
          );
        }
      } on MatchingFailure catch (failure) {
        emit(
          state.copyWith(
            status: failure is NoMatchesFailure
                ? MatchingStatus.empty
                : MatchingStatus.failure,
            profile: profile,
            isLoading: false,
            isGenerating: false,
            failure: failure,
          ),
        );
      } catch (error) {
        emit(
          state.copyWith(
            status: MatchingStatus.failure,
            profile: profile,
            isLoading: false,
            isGenerating: false,
            failure: UnknownFailure(error.toString()),
          ),
        );
      }
    } finally {
      _loadInFlight = false;
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

  Future<bool> performDeckAction(
    MatchItem match,
    MatchSwipeAction action,
  ) async {
    if (state.isSaving ||
        state.currentDeckIndex >= state.matches.length ||
        state.matches[state.currentDeckIndex].projectId != match.projectId) {
      return false;
    }

    emit(state.copyWith(isSaving: true, clearActionError: true));

    // Persist the like first — feedback is analytics and must not block saves.
    var removeSavedMatchOnUndo = false;
    if (action == MatchSwipeAction.request) {
      try {
        final saved = await _likedMatchesDataSource.getLikedMatches();
        final alreadySaved = saved.any(
          (savedMatch) => savedMatch.projectId == match.projectId,
        );
        if (!alreadySaved) {
          await _likedMatchesDataSource.addLikedMatch(
            match,
            promptVersion: state.promptVersion ?? _repository.promptVersion,
          );
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

    MatchFeedbackAction? previousFeedback;
    final saveMatchFeedback = _saveMatchFeedback;
    if (saveMatchFeedback != null) {
      final feedbackResult = await saveMatchFeedback(
        projectId: match.projectId,
        action: action == MatchSwipeAction.request
            ? MatchFeedbackAction.like
            : MatchFeedbackAction.skip,
        promptVersion: state.promptVersion ?? _repository.promptVersion,
      );
      switch (feedbackResult) {
        case Success(:final data):
          previousFeedback = data;
        case FailureResult():
          // Keep the deck moving; prompt-quality write is best-effort.
          break;
      }
    }

    final history = List<MatchActionRecord>.from(state.actionHistory)
      ..add(
        MatchActionRecord(
          index: state.currentDeckIndex,
          action: action,
          match: match,
          removesSavedMatchOnUndo: removeSavedMatchOnUndo,
          previousFeedback: previousFeedback,
        ),
      );
    final feedbackRecords = List<FeedbackRecord>.from(state.feedback)
      ..add(
        FeedbackRecord(
          id: 'action_${state.currentDeckIndex}_${match.projectId}',
          userId: state.profile.uid,
          projectId: match.projectId,
          action: action == MatchSwipeAction.request ? 'like' : 'skip',
          timestamp: DateTime.now(),
        ),
      );
    emit(
      state.copyWith(
        actionHistory: history,
        feedback: feedbackRecords,
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
    emit(state.copyWith(isSaving: true, clearActionError: true));

    final saveMatchFeedback = _saveMatchFeedback;
    if (saveMatchFeedback != null) {
      final previousFeedback = last.previousFeedback;
      final Result<void> undoFeedbackResult;
      if (previousFeedback == null) {
        undoFeedbackResult = await saveMatchFeedback.clear(
          projectId: last.match.projectId,
        );
      } else {
        final restoreResult = await saveMatchFeedback(
          projectId: last.match.projectId,
          action: previousFeedback,
        );
        undoFeedbackResult = switch (restoreResult) {
          Success() => const Success(null),
          FailureResult(:final failure) => FailureResult(failure),
        };
      }
      if (undoFeedbackResult case FailureResult(:final failure)) {
        emit(
          state.copyWith(isSaving: false, actionErrorMessage: failure.message),
        );
        return;
      }
    }

    if (last.removesSavedMatchOnUndo) {
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
    final feedbackRecords = List<FeedbackRecord>.from(state.feedback);
    if (feedbackRecords.isNotEmpty) {
      feedbackRecords.removeLast();
    }
    emit(
      state.copyWith(
        actionHistory: history,
        feedback: feedbackRecords,
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
