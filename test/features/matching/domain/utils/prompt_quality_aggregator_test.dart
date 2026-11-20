import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/feedback_record.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/utils/prompt_quality_aggregator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PromptQualityAggregator', () {
    test('returns null when no versioned feedback', () {
      final metrics = PromptQualityAggregator.aggregate(const [
        FeedbackRecord(
          id: '1',
          userId: 'u1',
          projectId: 'p1',
          action: 'like',
        ),
      ]);
      expect(metrics, isNull);
    });

    test('computes relevance per prompt version', () {
      final metrics = PromptQualityAggregator.aggregate([
        const FeedbackRecord(
          id: '1',
          userId: 'u1',
          projectId: 'p1',
          action: 'like',
          promptVersion: 'v1',
        ),
        const FeedbackRecord(
          id: '2',
          userId: 'u1',
          projectId: 'p2',
          action: 'skip',
          promptVersion: 'v1',
        ),
        const FeedbackRecord(
          id: '3',
          userId: 'u1',
          projectId: 'p3',
          action: 'like',
          promptVersion: 'v2',
        ),
      ]);

      expect(metrics, isNotNull);
      expect(metrics!.versions, hasLength(2));
      expect(metrics.versions[0].label, 'v1');
      expect(metrics.versions[0].relevance, 50);
      expect(metrics.versions[1].label, 'v2');
      expect(metrics.versions[1].relevance, 100);
      expect(metrics.averageMatchTime, isNull);
      expect(metrics.timelyAlertsPercentage, isNull);
    });
  });
}
