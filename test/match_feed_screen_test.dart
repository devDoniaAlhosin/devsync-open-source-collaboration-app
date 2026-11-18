import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/match_item.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/usecases/save_match_feedback.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/cubit/matching_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/match_feed_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/draggable_match_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/match_card_deck.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_dependencies.dart';
import 'helpers/fake_matching_feedback_repository.dart';

void main() {
  late MatchingCubit cubit;
  late FakeMatchingFeedbackRepository feedbackRepository;

  setUp(() async {
    await configureTestDependencies();
    feedbackRepository = FakeMatchingFeedbackRepository();
    cubit = MatchingCubit(
      repository: MatchingRepositoryImpl(
        remoteDataSource: MockMatchingRemoteDataSource(),
        localDataSource: InMemoryMatchingLocalDataSource(),
      ),
      saveMatchFeedback: SaveMatchFeedback(feedbackRepository),
    );
    await cubit.loadInitialData();
    cubit.setViewMode(MatchingViewMode.deck);
  });

  tearDown(() async {
    await cubit.close();
    await getIt.reset();
  });

  testWidgets('a left swipe completes a match as a skip', (tester) async {
    MatchSwipeAction? action;
    const match = MatchItem(
      projectId: 'project-1',
      projectName: 'flutter/packages',
      description: 'Packages for Flutter developers.',
      githubUrl: 'https://github.com/flutter/packages',
      neededSkills: ['Flutter', 'Dart', 'CI/CD'],
      score: 92,
      reason: 'Strong Flutter fit.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: DraggableMatchCard(
              match: match,
              onAction: (value) => action = value,
            ),
          ),
        ),
      ),
    );

    await tester.fling(
      find.byType(DraggableMatchCard),
      const Offset(-280, 0),
      1200,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(action, MatchSwipeAction.skip);
  });

  testWidgets('swiping the feed card advances to the next ranked project', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: getIt<AuthCubit>(),
          child: MatchFeedScreen(cubit: cubit),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('flutter/packages'), findsOneWidget);

    await tester.fling(
      find.byType(DraggableMatchCard),
      const Offset(-280, 0),
      1200,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('appwrite/appwrite'), findsOneWidget);
    expect(find.textContaining('flutter/packages skipped'), findsOneWidget);

    await tester.fling(
      find.byType(DraggableMatchCard),
      const Offset(280, 0),
      1200,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('pocketbase/pocketbase'), findsOneWidget);
  });

  testWidgets('failed feedback save restores the current card', (tester) async {
    feedbackRepository.result = const FailureResult(
      PermissionFailure('Feedback could not be saved.'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: getIt<AuthCubit>(),
          child: MatchFeedScreen(cubit: cubit),
        ),
      ),
    );
    await tester.pump();

    await tester.fling(
      find.byType(DraggableMatchCard),
      const Offset(-280, 0),
      1200,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('flutter/packages'), findsOneWidget);
    expect(find.text('Feedback could not be saved.'), findsOneWidget);
  });

  testWidgets('the feed stacks upcoming matches behind the draggable card', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: getIt<AuthCubit>(),
          child: MatchFeedScreen(cubit: cubit),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MatchCardDeck), findsOneWidget);
    expect(find.text('flutter/packages'), findsOneWidget);
    expect(find.text('appwrite/appwrite'), findsOneWidget);
    expect(find.text('pocketbase/pocketbase'), findsOneWidget);
  });
}
