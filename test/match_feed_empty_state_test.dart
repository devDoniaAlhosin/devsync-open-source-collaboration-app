import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/match_feed_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty feed actions call their respective handlers', (
    tester,
  ) async {
    var skills = 0;
    var github = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MatchFeedEmptyState(
            onAddSkills: () => skills++,
            onConnectGitHub: () => github++,
          ),
        ),
      ),
    );
    expect(find.text('No matches yet'), findsOneWidget);
    await tester.tap(find.text('Add skills'));
    await tester.tap(find.text('Connect GitHub'));
    expect(skills, 1);
    expect(github, 1);
  });

  testWidgets('empty feed scrolls on a small screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: MatchFeedEmptyState(onAddSkills: () {}, onConnectGitHub: () {}),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Connect GitHub'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Connect GitHub').hitTestable(), findsOneWidget);
  });
}
