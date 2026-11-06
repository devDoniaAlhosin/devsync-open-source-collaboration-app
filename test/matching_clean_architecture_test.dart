import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/liked_matches_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/matching_priority.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/user_profile.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/cubit/matching_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/ai_analytics_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/match_feed_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/draggable_match_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/matching/mocks/mock_matching_remote_data_source.dart';

const _testProfile = UserProfile(
  uid: 'test-uid-001',
  declaredSkills: ['Flutter', 'Dart'],
  githubLanguages: {'Dart': 80, 'Python': 20},
  publicRepoCount: 14,
  totalContributions: 200,
);

MatchingCubit _buildCubit() => MatchingCubit(
  repository: MatchingRepositoryImpl(
    remoteDataSource: MockMatchingRemoteDataSource(),
    localDataSource: InMemoryMatchingLocalDataSource(),
  ),
  likedMatchesDataSource: InMemoryLikedMatchesDataSource(),
  profile: _testProfile,
);

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
      });

      await tester.pumpWidget(
        MaterialApp(home: AiAnalyticsScreen(cubit: cubit)),
      );
      await tester.pump();

      expect(find.text('Match insights'), findsOneWidget);
      expect(find.text('Recommendation insights'), findsOneWidget);
      expect(find.text('Projects returned'), findsOneWidget);
      expect(find.text('Average match'), findsOneWidget);
      expect(find.text('Skill-based matches'), findsOneWidget);
    });
  });
}
