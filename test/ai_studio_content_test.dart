import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/matching_preferences.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_studio_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('studio synchronizes external prompts without emitting edits', (
    tester,
  ) async {
    final edits = <String>[];
    Widget buildStudio(String prompt) => MaterialApp(
      home: Scaffold(
        body: AiStudioContent(
          preferences: MatchingPreferences(prompt: prompt),
          matches: const [],
          scoringBreakdown: const {},
          isGenerating: false,
          onPromptChanged: edits.add,
          onTagToggled: (_) {},
          onGenerateMatches: () {},
          onViewProjectDetails: (_) {},
          onExploreAnalytics: () {},
        ),
      ),
    );
    await tester.pumpWidget(buildStudio('Initial prompt'));
    await tester.enterText(find.byType(TextField), 'Edited prompt');
    expect(edits, ['Edited prompt']);
    await tester.pumpWidget(buildStudio('Refined prompt'));
    expect(find.text('Refined prompt'), findsOneWidget);
    expect(edits, ['Edited prompt']);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
