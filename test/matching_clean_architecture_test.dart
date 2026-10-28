import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/matching_priority.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/controllers/matching_controller.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/ai_analytics_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/match_feed_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_analytics_stat_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_analytics_trend_chart.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_studio_preferences_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_studio_scoring_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_studio_suggested_matches_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/draggable_match_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MatchingController Clean Architecture & State Management', () {
    late MatchingRepositoryImpl repository;
    late MatchingController controller;

    setUp(() {
      repository = MatchingRepositoryImpl(
        remoteDataSource: MockMatchingRemoteDataSource(),
        localDataSource: InMemoryMatchingLocalDataSource(),
      );
      controller = MatchingController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('loadInitialData populates matches and analytics', () async {
      expect(controller.matches, isEmpty);
      await controller.loadInitialData();

      expect(controller.matches, isNotEmpty);
      expect(controller.analytics.matchesRated, 18);
      expect(controller.analytics.positiveSignalsPercentage, 83);
      expect(controller.analytics.skillsMatchedCount, 4);
    });

    test('generateMatches creates prompt-based recommendations', () async {
      await controller.loadInitialData();
      controller.updatePrompt('beginner-friendly testing tasks');
      await controller.generateMatches();

      expect(
        controller.matches.any((m) => m.projectName == 'nova-tools/cli'),
        isTrue,
      );
    });

    test('toggleTag updates active tags', () {
      expect(
        controller.preferences.selectedTags.contains('Flutter UI'),
        isTrue,
      );
      controller.toggleTag('Flutter UI');
      expect(
        controller.preferences.selectedTags.contains('Flutter UI'),
        isFalse,
      );
      controller.toggleTag('Flutter UI');
      expect(
        controller.preferences.selectedTags.contains('Flutter UI'),
        isTrue,
      );
    });

    test('refinePromptWithPriority sets template prompt and priority', () {
      controller.refinePromptWithPriority(MatchingPriority.beginnerFriendly);

      expect(
        controller.preferences.priority,
        MatchingPriority.beginnerFriendly,
      );
      expect(controller.preferences.prompt, contains('beginner-friendly'));
    });

    test('deck actions and undo work correctly', () async {
      await controller.loadInitialData();
      final firstMatch = controller.currentDeckMatch!;
      expect(controller.canUndo, isFalse);

      controller.performDeckAction(firstMatch, MatchSwipeAction.request);
      expect(controller.canUndo, isTrue);
      expect(controller.currentDeckIndex, 1);

      controller.undoLastDeckAction();
      expect(controller.canUndo, isFalse);
      expect(controller.currentDeckIndex, 0);
    });
  });

  group('Matching UI Components & Screens', () {
    late MatchingRepositoryImpl repository;
    late MatchingController controller;

    setUp(() {
      repository = MatchingRepositoryImpl(
        remoteDataSource: MockMatchingRemoteDataSource(),
        localDataSource: InMemoryMatchingLocalDataSource(),
      );
      controller = MatchingController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets(
      'MatchFeedScreen in studio mode renders all cards and elements',
      (tester) async {
        await tester.runAsync(() async {
          await controller.loadInitialData();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: MatchFeedScreen(
              controller: controller,
              initialViewMode: MatchingViewMode.studio,
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
          await controller.loadInitialData();
        });

        await tester.pumpWidget(
          MaterialApp(home: AiAnalyticsScreen(controller: controller)),
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
