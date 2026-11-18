import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/match_feedback_action.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/matching_priority.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/usecases/save_match_feedback.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/cubit/matching_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/ai_analytics_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/match_feed_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_analytics_stat_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_analytics_trend_chart.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_studio_preferences_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_studio_scoring_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_studio_suggested_matches_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/draggable_match_card.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_dependencies.dart';
import 'helpers/fake_matching_feedback_repository.dart';

void main() {
  group('MatchingCubit Clean Architecture & State Management', () {
    late MatchingRepositoryImpl repository;
    late FakeMatchingFeedbackRepository feedbackRepository;
    late MatchingCubit cubit;

    setUp(() async {
      await configureTestDependencies();
      feedbackRepository = FakeMatchingFeedbackRepository();
      repository = MatchingRepositoryImpl(
        remoteDataSource: MockMatchingRemoteDataSource(),
        localDataSource: InMemoryMatchingLocalDataSource(),
      );
      cubit = MatchingCubit(
        repository: repository,
        saveMatchFeedback: SaveMatchFeedback(feedbackRepository),
      );
    });

    tearDown(() async {
      await cubit.close();
      await getIt.reset();
    });

    test('loadInitialData populates matches and analytics', () async {
      expect(cubit.state.matches, isEmpty);
      await cubit.loadInitialData();

      expect(cubit.state.matches, isNotEmpty);
      expect(cubit.state.analytics.matchesRated, 18);
      expect(cubit.state.analytics.positiveSignalsPercentage, 83);
      expect(cubit.state.analytics.skillsMatchedCount, 4);
    });

    test('generateMatches creates prompt-based recommendations', () async {
      await cubit.loadInitialData();
      cubit.updatePrompt('beginner-friendly testing tasks');
      await cubit.generateMatches();

      expect(
        cubit.state.matches.any((m) => m.projectName == 'nova-tools/cli'),
        isTrue,
      );
    });

    test('toggleTag updates active tags', () {
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
      expect(cubit.state.preferences.prompt, contains('beginner-friendly'));
    });

    test('deck actions and undo work correctly', () async {
      await cubit.loadInitialData();
      final firstMatch = cubit.state.currentDeckMatch!;
      expect(cubit.state.canUndo, isFalse);

      final result = await cubit.performDeckAction(
        firstMatch,
        MatchSwipeAction.request,
      );
      expect(result, isA<Success<void>>());
      expect(cubit.state.canUndo, isTrue);
      expect(cubit.state.currentDeckIndex, 1);
      expect(feedbackRepository.savedFeedback, [
        (firstMatch.projectId, MatchFeedbackAction.like),
      ]);

      await cubit.undoLastDeckAction();
      expect(cubit.state.canUndo, isFalse);
      expect(cubit.state.currentDeckIndex, 0);
      expect(feedbackRepository.clearedFeedback, [firstMatch.projectId]);
    });

    test('failed feedback save keeps the current match active', () async {
      await cubit.loadInitialData();
      feedbackRepository.result = const FailureResult(
        PermissionFailure('Feedback could not be saved.'),
      );

      final result = await cubit.performDeckAction(
        cubit.state.currentDeckMatch!,
        MatchSwipeAction.skip,
      );

      expect(result, isA<FailureResult<void>>());
      expect(cubit.state.currentDeckIndex, 0);
      expect(cubit.state.actionHistory, isEmpty);
      expect(feedbackRepository.savedFeedback, isEmpty);
    });

    test('undo restores the previous feedback choice', () async {
      await cubit.loadInitialData();
      final match = cubit.state.currentDeckMatch!;
      await cubit.performDeckAction(match, MatchSwipeAction.request);

      await cubit.loadInitialData();
      await cubit.performDeckAction(match, MatchSwipeAction.skip);
      final result = await cubit.undoLastDeckAction();

      expect(result, isA<Success<void>>());
      expect(feedbackRepository.savedFeedback, [
        (match.projectId, MatchFeedbackAction.like),
        (match.projectId, MatchFeedbackAction.skip),
        (match.projectId, MatchFeedbackAction.like),
      ]);
    });
  });

  group('Matching UI Components & Screens', () {
    late MatchingRepositoryImpl repository;
    late FakeMatchingFeedbackRepository feedbackRepository;
    late MatchingCubit cubit;

    setUp(() async {
      await configureTestDependencies();
      feedbackRepository = FakeMatchingFeedbackRepository();
      repository = MatchingRepositoryImpl(
        remoteDataSource: MockMatchingRemoteDataSource(),
        localDataSource: InMemoryMatchingLocalDataSource(),
      );
      cubit = MatchingCubit(
        repository: repository,
        saveMatchFeedback: SaveMatchFeedback(feedbackRepository),
      );
    });

    tearDown(() async {
      await cubit.close();
      await getIt.reset();
    });

    testWidgets(
      'MatchFeedScreen in studio mode renders all cards and elements',
      (tester) async {
        await tester.runAsync(() async {
          await cubit.loadInitialData();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: getIt<AuthCubit>(),
              child: MatchFeedScreen(
                cubit: cubit,
                initialViewMode: MatchingViewMode.studio,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('DEVSYNC INTELLIGENCE / BETA'), findsOneWidget);
        expect(find.byType(AiStudioPreferencesCard), findsOneWidget);
        expect(find.byType(AiStudioSuggestedMatchesCard), findsOneWidget);
        expect(find.byType(AiStudioScoringCard), findsOneWidget);
        expect(find.text('Generate matches'), findsOneWidget);
        expect(find.text('How scoring works'), findsOneWidget);
      },
    );

    testWidgets(
      'AiAnalyticsScreen renders KPI metrics, trend chart and tuning',
      (tester) async {
        await tester.runAsync(() async {
          await cubit.loadInitialData();
        });

        await tester.pumpWidget(
          MaterialApp(home: AiAnalyticsScreen(cubit: cubit)),
        );
        await tester.pump();

        expect(find.text('MODEL TRANSPARENCY'), findsOneWidget);
        expect(find.text('Recommendation insights'), findsOneWidget);
        expect(find.byType(AiAnalyticsStatCard), findsNWidgets(3));
        expect(find.byType(AiAnalyticsTrendChart), findsOneWidget);
        expect(find.text('Tune your recommendations'), findsOneWidget);
        expect(find.text('Refine AI prompt'), findsOneWidget);
      },
    );
  });
}
