import '../entities/feedback_record.dart';
import '../entities/matching_analytics.dart';

class MatchingAnalyticsAggregator {
  const MatchingAnalyticsAggregator._();

  static MatchingAnalytics aggregate({
    required List<FeedbackRecord> feedback,
    required List<String> declaredSkills,
    Map<String, List<String>>? projectSkills,
  }) {
    if (feedback.isEmpty) {
      return MatchingAnalytics.empty;
    }

    final ratedCount = feedback.length;
    final likes = feedback.where((f) => f.isLike).toList();
    final positivePercentage = ((likes.length / ratedCount) * 100).round();

    final dailyTotal = <DateTime, int>{};
    final dailyLikes = <DateTime, int>{};

    for (final record in feedback) {
      final ts = record.timestamp;
      if (ts == null) continue;
      final day = DateTime(ts.year, ts.month, ts.day);
      dailyTotal[day] = (dailyTotal[day] ?? 0) + 1;
      if (record.isLike) {
        dailyLikes[day] = (dailyLikes[day] ?? 0) + 1;
      }
    }

    final sortedDays = dailyTotal.keys.toList()..sort();
    final List<double> trendValues;
    if (sortedDays.length >= 2) {
      trendValues = sortedDays.map((day) {
        final total = dailyTotal[day]!;
        final likeCount = dailyLikes[day] ?? 0;
        return (likeCount / total) * 100;
      }).toList();
    } else {
      trendValues = const [];
    }

    int? skillsMatchedCount;
    if (projectSkills != null &&
        declaredSkills.isNotEmpty &&
        likes.isNotEmpty) {
      final normalizedDeclared = declaredSkills
          .map((s) => s.trim().toLowerCase())
          .where((s) => s.isNotEmpty)
          .toSet();

      final likedProjectIds = likes.map((l) => l.projectId).toSet();
      final hasKnownProjectSkills = likedProjectIds.any(
        (id) => projectSkills.containsKey(id) && projectSkills[id]!.isNotEmpty,
      );

      if (hasKnownProjectSkills) {
        final matchedSkills = <String>{};
        for (final projectId in likedProjectIds) {
          final skills = projectSkills[projectId];
          if (skills != null) {
            for (final skill in skills) {
              final norm = skill.trim().toLowerCase();
              if (normalizedDeclared.contains(norm)) {
                matchedSkills.add(norm);
              }
            }
          }
        }
        skillsMatchedCount = matchedSkills.length;
      }
    }

    return MatchingAnalytics(
      ratedCount: ratedCount,
      positivePercentage: positivePercentage,
      trendValues: trendValues,
      skillsMatchedCount: skillsMatchedCount,
    );
  }
}
