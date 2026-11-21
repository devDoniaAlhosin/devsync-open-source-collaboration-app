import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/prompt_quality_metrics.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/prompt_quality_screen.dart';

void main() {
  group('PromptQualityScreen', () {
    testWidgets('shows "No data yet" when metrics are null and nothing loads', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: PromptQualityScreen(metrics: null)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Prompt quality'), findsOneWidget);
      expect(find.text('No data yet'), findsOneWidget);
      expect(find.textContaining('Like or skip matches'), findsOneWidget);
    });

    testWidgets('shows "No data yet" when metrics versions are empty', (
      tester,
    ) async {
      final emptyMetrics = PromptQualityMetrics(versions: const []);

      await tester.pumpWidget(
        MaterialApp(home: PromptQualityScreen(metrics: emptyMetrics)),
      );
      await tester.pump();

      expect(find.text('No data yet'), findsOneWidget);
    });

    testWidgets('renders real metrics when provided', (tester) async {
      final realMetrics = PromptQualityMetrics(
        versions: const [
          PromptQualityVersion(label: 'v1.0', relevance: 75),
          PromptQualityVersion(label: 'v2.0', relevance: 88),
        ],
        averageMatchTime: const Duration(seconds: 3),
        timelyAlertsPercentage: 95,
      );

      await tester.pumpWidget(
        MaterialApp(home: PromptQualityScreen(metrics: realMetrics)),
      );
      await tester.pump();

      expect(find.text('Snapshot'), findsOneWidget);
      expect(find.text('Avg match time'), findsOneWidget);
      expect(find.text('3s'), findsOneWidget);
      expect(find.text('Timely alerts'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
      expect(find.text('Relevance by prompt version'), findsOneWidget);
    });

    testWidgets('hides timing cards when timing metrics are absent', (
      tester,
    ) async {
      final metrics = PromptQualityMetrics(
        versions: const [PromptQualityVersion(label: 'v1', relevance: 60)],
      );

      await tester.pumpWidget(
        MaterialApp(home: PromptQualityScreen(metrics: metrics)),
      );
      await tester.pump();

      expect(find.text('Relevance by prompt version'), findsOneWidget);
      expect(find.text('Avg match time'), findsNothing);
      expect(find.text('Timely alerts'), findsNothing);
    });
  });
}
