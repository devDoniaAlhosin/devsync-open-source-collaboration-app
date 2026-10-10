import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devsync_open_source_collaboration_app/app/devsync_app.dart';

void main() {
  testWidgets('Intro launch screen shows CTA', (tester) async {
    await tester.pumpWidget(const DevSyncApp(showSplash: false));
    await tester.pump();

    expect(find.textContaining('Find your people'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
  });

  testWidgets('Welcome carousel opens from intro', (tester) async {
    await tester.pumpWidget(const DevSyncApp(showSplash: false));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Get started'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Get started'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Code with the right people.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Login screen opens from intro Sign in', (tester) async {
    await tester.pumpWidget(const DevSyncApp(showSplash: false));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Sign in →'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Sign in →'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Your workspace awaits.'), findsOneWidget);
    expect(find.text('Work email'), findsOneWidget);
    expect(find.text('Sign in with email code'), findsOneWidget);
  });
}
