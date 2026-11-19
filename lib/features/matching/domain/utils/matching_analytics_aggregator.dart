import '../entities/feedback_record.dart';
import '../entities/matching_analytics.dart';

/// Aggregates raw feedback records and project/profile data into [MatchingAnalytics].
class MatchingAnalyticsAggregator {
  const MatchingAnalyticsAggregator._();

  /// Computes [MatchingAnalytics] from real user feedback.
  ///
  /// - [ratedCount] = count of feedback records.
  /// - [positivePercentage] = likes ÷ rated * 100 (null if rated == 0).
  /// - [trendValues] = positive % per day, chronologically ascending.
  ///   Empty if fewer than 2 distinct days.
  /// - [skillsMatchedCount] = overlap between [declaredSkills] and skills of
  ///   liked projects from [projectSkills]. Null if not computable.
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

    // Trend: positive % per day (needs >= 2 distinct days)
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

    // Skills matched: computable only if we have project skills for liked projects
    // and the user has declared skills.
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
