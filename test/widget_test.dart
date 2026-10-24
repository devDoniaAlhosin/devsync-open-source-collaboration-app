import 'package:flutter_test/flutter_test.dart';

import 'package:devsync_open_source_collaboration_app/app/devsync_app.dart';
import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';

import 'helpers/test_dependencies.dart';

void main() {
  setUp(() async {
    await configureTestDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('Welcome opens after splash gate', (tester) async {
    await tester.pumpWidget(const DevSyncApp(showSplash: false));
    await tester.pump();

    expect(find.text('Code with the right people.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Discover · Match · Ship'), findsOneWidget);
  });

  testWidgets('Welcome Next advances carousel', (tester) async {
    await tester.pumpWidget(const DevSyncApp(showSplash: false));
    await tester.pump();

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Know exactly why it fits.'), findsOneWidget);
  });

  testWidgets('Login opens from Welcome Sign in', (tester) async {
    await tester.pumpWidget(const DevSyncApp(showSplash: false));
    await tester.pump();

    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Your workspace awaits.'), findsOneWidget);
    expect(find.text('Work email'), findsOneWidget);
    expect(find.text('Sign in with email link'), findsOneWidget);
  });
}
