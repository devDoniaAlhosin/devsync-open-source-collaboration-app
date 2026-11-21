import 'package:flutter_test/flutter_test.dart';

import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/feedback_record.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/utils/matching_analytics_aggregator.dart';

FeedbackRecord _record({
  required String id,
  required String projectId,
  required String action,
  DateTime? timestamp,
}) => FeedbackRecord(
  id: id,
  userId: 'user-001',
  projectId: projectId,
  action: action,
  timestamp: timestamp,
);

void main() {
  group('MatchingAnalyticsAggregator', () {
    test('returns empty analytics when feedback is empty', () {
      final analytics = MatchingAnalyticsAggregator.aggregate(
        feedback: const [],
        declaredSkills: const ['Flutter', 'Dart'],
      );

      expect(analytics.isEmpty, isTrue);
      expect(analytics.ratedCount, 0);
      expect(analytics.positivePercentage, isNull);
      expect(analytics.trendValues, isEmpty);
      expect(analytics.hasEnoughTrendData, isFalse);
      expect(analytics.skillsMatchedCount, isNull);
    });

    test('calculates rated count and positive percentage correctly', () {
      final feedback = [
        _record(id: '1', projectId: 'p1', action: 'like'),
        _record(id: '2', projectId: 'p2', action: 'like'),
        _record(id: '3', projectId: 'p3', action: 'skip'),
        _record(id: '4', projectId: 'p4', action: 'skip'),
      ];

      final analytics = MatchingAnalyticsAggregator.aggregate(
        feedback: feedback,
        declaredSkills: const ['Flutter'],
      );

      expect(analytics.isEmpty, isFalse);
      expect(analytics.ratedCount, 4);
      // 2 positive (like) out of 4 = 50%
      expect(analytics.positivePercentage, 50);
    });

    test('computes trend only when >= 2 distinct days are available', () {
      final day1 = DateTime(2024, 3, 1, 10, 0);
      final day1Later = DateTime(2024, 3, 1, 15, 0);
      final day2 = DateTime(2024, 3, 2, 9, 0);

      // Only 1 day -> not enough trend data
      final singleDayFeedback = [
        _record(id: '1', projectId: 'p1', action: 'like', timestamp: day1),
        _record(id: '2', projectId: 'p2', action: 'skip', timestamp: day1Later),
      ];

      final singleDayAnalytics = MatchingAnalyticsAggregator.aggregate(
        feedback: singleDayFeedback,
        declaredSkills: const ['Dart'],
      );

      expect(singleDayAnalytics.trendValues, isEmpty);
      expect(singleDayAnalytics.hasEnoughTrendData, isFalse);

      // 2 days -> yields 2 trend points sorted chronologically
      final multiDayFeedback = [
        _record(id: '1', projectId: 'p1', action: 'like', timestamp: day1),
        _record(id: '2', projectId: 'p2', action: 'skip', timestamp: day1Later),
        _record(id: '3', projectId: 'p3', action: 'like', timestamp: day2),
      ];

      final multiDayAnalytics = MatchingAnalyticsAggregator.aggregate(
        feedback: multiDayFeedback,
        declaredSkills: const ['Dart'],
      );

      expect(multiDayAnalytics.hasEnoughTrendData, isTrue);
      expect(multiDayAnalytics.trendValues.length, 2);
      // Day 1: 1 like out of 2 = 50.0%
      expect(multiDayAnalytics.trendValues[0], 50.0);
      // Day 2: 1 like out of 1 = 100.0%
      expect(multiDayAnalytics.trendValues[1], 100.0);
    });

    test('ignores records with null timestamp for trend calculation', () {
      final day1 = DateTime(2024, 3, 1);
      final feedback = [
        _record(id: '1', projectId: 'p1', action: 'like', timestamp: day1),
        _record(id: '2', projectId: 'p2', action: 'skip', timestamp: null),
      ];

      final analytics = MatchingAnalyticsAggregator.aggregate(
        feedback: feedback,
        declaredSkills: const ['Dart'],
      );

      expect(analytics.ratedCount, 2);
      expect(analytics.trendValues, isEmpty);
      expect(analytics.hasEnoughTrendData, isFalse);
    });

    test('computes skillsMatchedCount from liked projects only', () {
      final feedback = [
        _record(id: '1', projectId: 'p1', action: 'like'),
        _record(id: '2', projectId: 'p2', action: 'skip'), // skip ignored
      ];

      final projectSkills = {
        'p1': ['Flutter', 'Dart', 'Python'],
        'p2': ['Java', 'Kotlin'],
      };

      final analytics = MatchingAnalyticsAggregator.aggregate(
        feedback: feedback,
        declaredSkills: const ['flutter', 'dart', 'rust'],
        projectSkills: projectSkills,
      );

      // 'flutter' and 'dart' match with p1
      expect(analytics.skillsMatchedCount, 2);
    });

    test(
      'skillsMatchedCount is null when project skills are not available',
      () {
        final feedback = [_record(id: '1', projectId: 'p1', action: 'like')];

        final analytics = MatchingAnalyticsAggregator.aggregate(
          feedback: feedback,
          declaredSkills: const ['Flutter', 'Dart'],
          projectSkills: null,
        );

        expect(analytics.skillsMatchedCount, isNull);
      },
    );

    test('skillsMatchedCount is null when user has no declared skills', () {
      final feedback = [_record(id: '1', projectId: 'p1', action: 'like')];

      final analytics = MatchingAnalyticsAggregator.aggregate(
        feedback: feedback,
        declaredSkills: const [],
        projectSkills: {
          'p1': ['Flutter'],
        },
      );

      expect(analytics.skillsMatchedCount, isNull);
    });
  });
}
