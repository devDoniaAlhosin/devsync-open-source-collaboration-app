import 'package:flutter_test/flutter_test.dart';

import 'package:devsync_open_source_collaboration_app/app/devsync_app.dart';

void main() {
  testWidgets('Welcome screen shows DevSync branding', (tester) async {
    await tester.pumpWidget(const DevSyncApp());
    await tester.pump();

    expect(find.text('DevSync'), findsOneWidget);
    expect(find.text('Code with the right people.'), findsOneWidget);
    expect(find.text('Design system gallery'), findsOneWidget);
  });

  testWidgets('Design system gallery opens from welcome', (tester) async {
    await tester.pumpWidget(const DevSyncApp());
    await tester.pump();

    await tester.tap(find.text('Design system gallery'));
    // Score meter uses a short TweenAnimationBuilder — advance past it.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Design system'), findsOneWidget);
    expect(find.text('Buttons'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
  });
}
