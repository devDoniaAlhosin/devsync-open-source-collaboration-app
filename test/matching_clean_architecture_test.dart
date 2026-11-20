import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/liked_matches_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_item_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_request_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_response_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/matching_priority.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/user_profile.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/failures/matching_failures.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/usecases/get_ranked_matches_usecase.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/cubit/matching_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/ai_analytics_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/match_feed_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/draggable_match_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _testProfile = UserProfile(
  uid: 'test-uid-001',
  declaredSkills: ['Flutter', 'Dart'],
  githubLanguages: {'Dart': 80, 'Python': 20},
  publicRepoCount: 14,
  totalContributions: 200,
);

/// Test-only stub that mirrors the original MockMatchingRemoteDataSource sample
/// data. The production code no longer ships a mock implementation.
class _DefaultRemoteDataSource implements MatchingRemoteDataSource {
  @override
  Future<MatchResponseModel> getMatches(MatchRequestModel request) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return const MatchResponseModel(
      promptVersion: 'v1-sample',
      matches: [
        MatchItemModel(
          projectId: 'sample-1',
          projectName: 'flutter/packages',
          description:
              'A collection of useful packages maintained by the Flutter team.',
          githubUrl: 'https://github.com/flutter/packages',
          neededSkills: ['Flutter', 'Dart', 'CI/CD'],
          score: 92,
          reason:
              'Strong Dart and Flutter activity with CI contributions matching project needs.',
        ),
        MatchItemModel(
          projectId: 'sample-2',
          projectName: 'appwrite/appwrite',
          description:
              'Open-source backend server for web, mobile, and Flutter developers.',
          githubUrl: 'https://github.com/appwrite/appwrite',
          neededSkills: ['Flutter', 'REST APIs', 'Docker'],
          score: 78,
          reason:
              'Flutter SDK experience aligns well; REST API skills are a bonus.',
        ),
        MatchItemModel(
          projectId: 'sample-3',
          projectName: 'pocketbase/pocketbase',
          description:
              'Open-source backend in a single file — real-time DB, auth, file storage.',
          githubUrl: 'https://github.com/pocketbase/pocketbase',
          neededSkills: ['Go', 'SQLite', 'REST APIs'],
          score: 55,
          reason:
              'REST API overlap; Go is a growth opportunity given your backend interest.',
        ),
      ],
    );
  }

  @override
  void close() {}
}

class _FailingRemoteDataSource implements MatchingRemoteDataSource {
  _FailingRemoteDataSource([this.failure]);
  final MatchingFailure? failure;

  @override
  Future<MatchResponseModel> getMatches(MatchRequestModel request) async {
    throw failure ?? const NetworkFailure();
  }

  @override
  void close() {}
}

class _CountingRemoteDataSource implements MatchingRemoteDataSource {
  _CountingRemoteDataSource(this.response);
  MatchResponseModel response;
  int callCount = 0;
  List<MatchRequestModel> requests = [];

  @override
  Future<MatchResponseModel> getMatches(MatchRequestModel request) async {
    callCount++;
    requests.add(request);
    return response;
  }

  @override
  void close() {}
}

MatchingCubit _buildCubit({
  MatchingRemoteDataSource? remoteDataSource,
  UserProfile? profile,
}) {
  final repository = MatchingRepositoryImpl(
    remoteDataSource: remoteDataSource ?? _DefaultRemoteDataSource(),
    localDataSource: InMemoryMatchingLocalDataSource(),
  );
  return MatchingCubit(
    repository: repository,
    likedMatchesDataSource: InMemoryLikedMatchesDataSource(),
    getRankedMatchesUseCase: GetRankedMatchesUseCase(repository),
    profile: profile ?? _testProfile,
  );
}

void main() {
  group('MatchingCubit Clean Architecture & State Management', () {
    late MatchingCubit cubit;

    setUp(() {
      cubit = _buildCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state has empty matches and no error', () {
      expect(cubit.state.matches, isEmpty);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.isLoading, isFalse);
    });

    test('loadInitialData populates matches from mock data source', () async {
      expect(cubit.state.matches, isEmpty);
      await cubit.loadInitialData();

      // MockMatchingRemoteDataSource returns 3 items sorted descending by score
      expect(cubit.state.matches.length, 3);
      expect(
        cubit.state.matches.first.score,
        greaterThanOrEqualTo(cubit.state.matches.last.score),
      );
      expect(cubit.state.promptVersion, 'v1-sample');
      expect(cubit.state.errorMessage, isNull);
    });

    test('matches are ranked highest score first', () async {
      await cubit.loadInitialData();
      final scores = cubit.state.matches.map((m) => m.score).toList();
      for (var i = 0; i < scores.length - 1; i++) {
        expect(scores[i], greaterThanOrEqualTo(scores[i + 1]));
      }
    });

    test('generateMatches creates prompt-based recommendations', () async {
      await cubit.loadInitialData();
      cubit.updatePrompt('beginner-friendly testing tasks');
      await cubit.generateMatches();

      expect(cubit.state.matches, isNotEmpty);
      expect(cubit.state.isGenerating, isFalse);
    });

    test('toggleTag updates active tags', () {
      // Default preferences start with no selected tags
      cubit.toggleTag('Flutter UI');
      expect(
        cubit.state.preferences.selectedTags.contains('Flutter UI'),
        isTrue,
      );
      cubit.toggleTag('Flutter UI');
      expect(
        cubit.state.preferences.selectedTags.contains('Flutter UI'),
        isFalse,
      );
      cubit.toggleTag('Flutter UI');
      expect(
        cubit.state.preferences.selectedTags.contains('Flutter UI'),
        isTrue,
      );
    });

    test('refinePromptWithPriority sets template prompt and priority', () {
      cubit.refinePromptWithPriority(MatchingPriority.beginnerFriendly);

      expect(
        cubit.state.preferences.priority,
        MatchingPriority.beginnerFriendly,
      );
      expect(cubit.state.preferences.prompt, contains('beginner'));
    });

    test('deck actions and undo work correctly', () async {
      await cubit.loadInitialData();
      cubit.setViewMode(MatchingViewMode.deck);
      final firstMatch = cubit.state.currentDeckMatch!;
      expect(cubit.state.canUndo, isFalse);

      await cubit.performDeckAction(firstMatch, MatchSwipeAction.request);
      expect(cubit.state.canUndo, isTrue);
      expect(cubit.state.currentDeckIndex, 1);

      await cubit.undoLastDeckAction();
      expect(cubit.state.canUndo, isFalse);
      expect(cubit.state.currentDeckIndex, 0);
    });

    test(
      'prompt over 1000 chars produces validation error, not crash',
      () async {
        await cubit.loadInitialData();
        cubit.updatePrompt('x' * 1001);
        await cubit.generateMatches();
        expect(cubit.state.errorMessage, isNotNull);
        expect(cubit.state.isGenerating, isFalse);
      },
    );

    test('initial state has MatchingStatus.initial and isInitial true', () {
      expect(cubit.state.status, MatchingStatus.initial);
      expect(cubit.state.isInitial, isTrue);
      expect(cubit.state.isSuccess, isFalse);
      expect(cubit.state.isFailure, isFalse);
    });

    test('loading and success state transitions on loadInitialData', () async {
      final statuses = <MatchingStatus>[];
      final sub = cubit.stream.listen((s) => statuses.add(s.status));
      await cubit.loadInitialData();
      await pumpEventQueue();
      expect(
        statuses,
        containsAllInOrder([MatchingStatus.loading, MatchingStatus.success]),
      );
      expect(cubit.state.status, MatchingStatus.success);
      expect(cubit.state.isSuccess, isTrue);
      await sub.cancel();
    });

    test('empty state when user profile has empty declaredSkills', () async {
      final emptySkillsCubit = _buildCubit(
        profile: const UserProfile(
          uid: 'no-skills',
          declaredSkills: [],
          githubLanguages: {},
          publicRepoCount: 0,
          totalContributions: 0,
        ),
      );
      await emptySkillsCubit.loadInitialData();
      expect(emptySkillsCubit.state.status, MatchingStatus.empty);
      expect(emptySkillsCubit.state.isEmptyState, isTrue);
      expect(emptySkillsCubit.state.failure, isA<NoMatchesFailure>());
      await emptySkillsCubit.close();
    });

    test('empty state when remote returns empty matches', () async {
      final emptyRemote = _CountingRemoteDataSource(
        const MatchResponseModel(promptVersion: 'v1', matches: []),
      );
      final emptyCubit = _buildCubit(remoteDataSource: emptyRemote);
      await emptyCubit.loadInitialData();
      expect(emptyCubit.state.status, MatchingStatus.empty);
      expect(emptyCubit.state.isEmptyState, isTrue);
      expect(emptyCubit.state.failure, isA<NoMatchesFailure>());
      await emptyCubit.close();
    });

    test('failure state when remote throws MatchingFailure', () async {
      final failingCubit = _buildCubit(
        remoteDataSource: _FailingRemoteDataSource(const NetworkFailure()),
      );
      await failingCubit.loadInitialData();
      expect(failingCubit.state.status, MatchingStatus.failure);
      expect(failingCubit.state.isFailure, isTrue);
      expect(failingCubit.state.failure, isA<NetworkFailure>());
      await failingCubit.close();
    });

    test(
      'retry repeats loadInitialData when last request was loadInitialData',
      () async {
        final countingRemote = _CountingRemoteDataSource(
          const MatchResponseModel(promptVersion: 'v1', matches: []),
        );
        final retryCubit = _buildCubit(remoteDataSource: countingRemote);
        await retryCubit.loadInitialData();
        expect(countingRemote.callCount, 1);
        expect(countingRemote.requests.last.prompt, isNull);
        await retryCubit.retry();
        expect(countingRemote.callCount, 2);
        expect(countingRemote.requests.last.prompt, isNull);
        await retryCubit.close();
      },
    );

    test(
      'retry repeats generateMatches when last request was generateMatches',
      () async {
        final countingRemote = _CountingRemoteDataSource(
          const MatchResponseModel(promptVersion: 'v1', matches: []),
        );
        final retryCubit = _buildCubit(remoteDataSource: countingRemote);
        retryCubit.updatePrompt('flutter widgets');
        await retryCubit.generateMatches();
        expect(countingRemote.callCount, 1);
        expect(countingRemote.requests.last.prompt, 'flutter widgets');
        await retryCubit.retry();
        expect(countingRemote.callCount, 2);
        expect(countingRemote.requests.last.prompt, 'flutter widgets');
        await retryCubit.close();
      },
    );

    test('analytics reflects deck swipe actions and skill overlap', () async {
      await cubit.loadInitialData();
      expect(cubit.analytics.isEmpty, isTrue);

      await cubit.performDeckAction(
        cubit.state.matches.first,
        MatchSwipeAction.request,
      );

      expect(cubit.analytics.isEmpty, isFalse);
      expect(cubit.analytics.ratedCount, 1);
      expect(cubit.analytics.positivePercentage, 100);
      expect(cubit.analytics.skillsMatchedCount, 2);
    });
  });

  group('Matching UI Components & Screens', () {
    late MatchingCubit cubit;

    setUp(() {
      cubit = _buildCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    testWidgets(
      'MatchFeedScreen in deck mode shows DraggableMatchCard after load',
      (tester) async {
        await tester.runAsync(() async {
          await cubit.loadInitialData();
        });
        cubit.setViewMode(MatchingViewMode.deck);

        await tester.pumpWidget(
          MaterialApp(
            home: MatchFeedScreen(
              cubit: cubit,
              initialViewMode: MatchingViewMode.deck,
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DraggableMatchCard), findsOneWidget);
        expect(find.text('flutter/packages'), findsOneWidget);
      },
    );

    testWidgets('AiAnalyticsScreen renders stat cards and transparency card', (
      tester,
    ) async {
      await tester.runAsync(() async {
        await cubit.loadInitialData();
        await cubit.performDeckAction(
          cubit.state.matches.first,
          MatchSwipeAction.request,
        );
      });

      await tester.pumpWidget(
        MaterialApp(home: AiAnalyticsScreen(cubit: cubit)),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI Analytics'), findsOneWidget);
      expect(find.text('Recommendation insights'), findsOneWidget);
      expect(find.text('Matches rated'), findsOneWidget);
      expect(find.text('Positive signals'), findsOneWidget);
      expect(find.text('Skills matched'), findsOneWidget);
    });

    testWidgets(
      'AiAnalyticsScreen shows demo analytics when user has zero ratings',
      (tester) async {
        await tester.runAsync(() async {
          await cubit.loadInitialData();
        });

        await tester.pumpWidget(
          MaterialApp(home: AiAnalyticsScreen(cubit: cubit)),
        );
        await tester.pumpAndSettle();

        // With zero real ratings the screen falls back to demoAnalytics
        // (spec: "Data today: MatchingAnalytics.demoAnalytics").
        expect(find.text('Recommendation insights'), findsOneWidget);
        expect(find.text('Matches rated'), findsOneWidget);
      },
    );
  });
}
