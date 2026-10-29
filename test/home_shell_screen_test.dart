import 'package:devsync_open_source_collaboration_app/features/shell/home_shell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home navigation destinations resolve material localizations', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeShellScreen()));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
