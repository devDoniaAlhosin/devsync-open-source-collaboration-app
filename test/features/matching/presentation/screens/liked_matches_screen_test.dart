import 'package:devsync_open_source_collaboration_app/core/theme/app_theme.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/liked_matches_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/match_item.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/liked_matches_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject(LikedMatchesDataSource dataSource) {
    return MaterialApp(
      theme: AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: LikedMatchesScreen(dataSource: dataSource),
    );
  }

  testWidgets('renders a saved match with its score, skills, and actions', (
    tester,
  ) async {
    final dataSource = InMemoryLikedMatchesDataSource();
    await dataSource.addLikedMatch(
      const MatchItem(
        projectId: 'flutter-oss-charts',
        projectName: 'flutter-oss/charts',
        description: 'Needs a Dart contributor',
        githubUrl: 'https://github.com/flutter-oss/charts',
        neededSkills: ['Dart', 'Firebase', 'Animation'],
        score: 92,
        reason: 'Strong fit for your Flutter experience.',
      ),
    );

    await tester.pumpWidget(buildSubject(dataSource));
    await tester.pump();

    expect(find.text('Liked matches'), findsOneWidget);
    expect(find.text('You · like/skip'), findsOneWidget);
    expect(find.text('flutter-oss/charts'), findsOneWidget);
    expect(find.text('Needs a Dart contributor'), findsOneWidget);
    expect(find.text('92'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('Firebase'), findsOneWidget);
    expect(find.text('Animation'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Request'), findsOneWidget);
  });

  testWidgets('shows the empty state when no matches have been liked', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(InMemoryLikedMatchesDataSource()));
    await tester.pump();

    expect(find.text('No liked matches yet'), findsOneWidget);
    expect(
      find.text('Like a card on Matches and it will show up here.'),
      findsOneWidget,
    );
  });
}
