import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/app/devsync_app.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/project_details_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/draggable_match_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping a match card opens details for that project', (
    tester,
  ) async {
    await tester.pumpWidget(const DevSyncApp(showSplash: false));
    await tester.pump();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(AppRoutes.feed);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byType(DraggableMatchCard));
    await tester.pumpAndSettle();

    expect(find.text('Project details'), findsOneWidget);
    expect(find.text('flutter/packages'), findsOneWidget);
    expect(find.text('Overall match'), findsOneWidget);
    expect(find.text('Skill coverage'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('Preview project workspace'), findsOneWidget);
    expect(find.text('Request to collaborate'), findsOneWidget);
  });

  testWidgets('shows an empty state when project arguments are absent', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectDetailsScreen()));

    expect(find.text('No project selected'), findsOneWidget);
  });
}
