import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/match_feed_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/draggable_match_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/match_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
    await tester.pumpWidget(const MaterialApp(home: MatchFeedScreen()));
    await tester.pump(const Duration(seconds: 1));

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
}
