import 'package:flutter/foundation.dart';

import '../../domain/entities/match_item.dart';
import '../../domain/entities/matching_analytics.dart';
import '../../domain/entities/matching_preferences.dart';
import '../../domain/entities/matching_priority.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/matching_repository.dart';
import '../../domain/usecases/generate_matches_usecase.dart';
import '../../domain/usecases/get_matching_analytics_usecase.dart';
import '../../domain/usecases/get_ranked_matches_usecase.dart';
import '../widgets/draggable_match_card.dart';

class MatchActionRecord {
  final int index;

  final MatchSwipeAction action;
  final MatchItem match;
  const MatchActionRecord({
    required this.index,
    required this.action,
    required this.match,
  });
}

/// Controller managing Matching Feature state and business logic.
///
/// Follows Single Responsibility and Dependency Inversion by depending
/// on use cases / domain abstractions.
class MatchingController extends ChangeNotifier {
  static const defaultProfile = UserProfile(
    uid: 'demo-user',
    declaredSkills: ['Flutter', 'Dart', 'Firebase'],
    githubLanguages: {'Dart': 60, 'Python': 20, 'JavaScript': 10},
    publicRepoCount: 12,
    totalContributions: 340,
    bio: 'Mobile developer interested in open source.',
  );

  final GetRankedMatchesUseCase _getRankedMatchesUseCase;
  final GenerateMatchesUseCase _generateMatchesUseCase;
  final GetMatchingAnalyticsUseCase _getMatchingAnalyticsUseCase;
  final UserProfile _profile;

  // State
  bool _isLoading = false;

  bool _isGenerating = false;
  String? _errorMessage;
  List<MatchItem> _matches = const [];
  MatchingAnalytics _analytics = MatchingAnalytics.demoAnalytics;
  MatchingPreferences _preferences = MatchingPreferences.defaultPreferences;
  MatchingViewMode _viewMode = MatchingViewMode.studio;
  int _currentDeckIndex = 0;
  final List<MatchActionRecord> _actionHistory = [];
  MatchingController({
    required MatchingRepository repository,
    UserProfile? profile,
  }) : _getRankedMatchesUseCase = GetRankedMatchesUseCase(repository),
       _generateMatchesUseCase = GenerateMatchesUseCase(repository),
       _getMatchingAnalyticsUseCase = GetMatchingAnalyticsUseCase(repository),
       _profile = profile ?? defaultProfile;

  List<MatchActionRecord> get actionHistory =>
      List.unmodifiable(_actionHistory);
  MatchingAnalytics get analytics => _analytics;
  bool get canUndo => _actionHistory.isNotEmpty;
  int get currentDeckIndex => _currentDeckIndex;
  MatchItem? get currentDeckMatch {
    if (_matches.isEmpty || _currentDeckIndex >= _matches.length) return null;
    return _matches[_currentDeckIndex];
  }

  String? get errorMessage => _errorMessage;
  bool get hasMatches => _matches.isNotEmpty;
  bool get isGenerating => _isGenerating;
  // Getters
  bool get isLoading => _isLoading;
  List<MatchItem> get matches => _matches;
  List<MatchItem> get nextDeckMatches {
    if (_matches.isEmpty) return const [];
    return _matches.skip(_currentDeckIndex + 1).take(2).toList();
  }

  MatchingPreferences get preferences => _preferences;

  UserProfile get profile => _profile;

  MatchingViewMode get viewMode => _viewMode;

  Future<void> generateMatches() async {
    _isGenerating = true;
    notifyListeners();

    try {
      final results = await _generateMatchesUseCase(
        prompt: _preferences.prompt,
        tags: _preferences.selectedTags,
      );

      _matches = results;
      _currentDeckIndex = 0;
      _actionHistory.clear();
      _isGenerating = false;
      notifyListeners();
    } catch (e) {
      _isGenerating = false;
      _errorMessage = 'Failed to generate recommendations.';
      notifyListeners();
    }
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _getRankedMatchesUseCase(_profile);
      final analyticsData = await _getMatchingAnalyticsUseCase();

      _matches = results;
      _analytics = analyticsData;
      _currentDeckIndex = 0;
      _actionHistory.clear();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Could not load matches. Please try again.';
      notifyListeners();
    }
  }

  void performDeckAction(MatchItem match, MatchSwipeAction action) {
    if (_currentDeckIndex >= _matches.length ||
        _matches[_currentDeckIndex].projectId != match.projectId) {
      return;
    }

    _actionHistory.add(
      MatchActionRecord(index: _currentDeckIndex, action: action, match: match),
    );
    _currentDeckIndex++;
    notifyListeners();
  }

  void refinePromptWithPriority(MatchingPriority priority) {
    _preferences = _preferences.copyWith(
      priority: priority,
      prompt: priority.promptTemplate,
    );
    notifyListeners();
  }

  void setPriority(MatchingPriority priority) {
    if (_preferences.priority == priority) return;
    _preferences = _preferences.copyWith(priority: priority);
    notifyListeners();
  }

  void setViewMode(MatchingViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  void toggleTag(String tag) {
    final updated = Set<String>.from(_preferences.selectedTags);
    if (updated.contains(tag)) {
      updated.remove(tag);
    } else {
      updated.add(tag);
    }
    _preferences = _preferences.copyWith(selectedTags: updated);
    notifyListeners();
  }

  void undoLastDeckAction() {
    if (_actionHistory.isEmpty) return;
    final last = _actionHistory.removeLast();
    _currentDeckIndex = last.index;
    notifyListeners();
  }

  void updatePrompt(String text) {
    if (_preferences.prompt == text) return;
    _preferences = _preferences.copyWith(prompt: text);
    notifyListeners();
  }
}

enum MatchingViewMode { studio, deck }
