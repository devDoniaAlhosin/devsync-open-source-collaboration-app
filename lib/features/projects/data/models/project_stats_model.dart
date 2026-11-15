import '../../domain/entities/project_stats.dart';

/// Pure mapping helpers shared by the project data sources.
abstract final class ProjectStatsModel {
  static const fallbackSummary =
      'Skill alignment will appear once the AI matching engine analyses your '
      'profile against this project.';

  /// Keeps the sparkline stable at seven buckets, oldest first.
  static List<double> normalizeWeeklyViews(List<double> values) {
    if (values.length == 7) {
      return List<double>.unmodifiable(values);
    }
    if (values.length > 7) {
      return List<double>.unmodifiable(values.sublist(values.length - 7));
    }
    return List<double>.unmodifiable([
      ...List<double>.filled(7 - values.length, 0),
      ...values,
    ]);
  }

  static ProjectStats fromParts({
    required int stars,
    required int contributors,
    required int openTasks,
    required String ownerName,
    required DateTime? updatedAt,
    required String matchSummary,
    required List<SkillAlignment> alignments,
    required List<String> matchedSkills,
    required List<double> weeklyViews,
    String ownerResponseTime = 'Usually replies in 1 day',
  }) {
    return ProjectStats(
      stars: stars,
      contributors: contributors,
      openTasks: openTasks,
      ownerName: ownerName,
      ownerResponseTime: ownerResponseTime,
      updatedLabel: relativeUpdatedLabel(updatedAt),
      matchSummary: matchSummary.trim().isEmpty
          ? fallbackSummary
          : matchSummary.trim(),
      alignments: alignments,
      matchedSkills: matchedSkills,
      weeklyViews: normalizeWeeklyViews(weeklyViews),
    );
  }
}

String relativeUpdatedLabel(DateTime? updatedAt) {
  if (updatedAt == null) return 'Updated recently';

  final difference = DateTime.now().difference(updatedAt);
  if (difference.isNegative || difference.inMinutes < 60) {
    return 'Updated just now';
  }
  if (difference.inHours < 24) {
    return difference.inHours == 1
        ? 'Updated 1 hour ago'
        : 'Updated ${difference.inHours} hours ago';
  }
  if (difference.inDays < 7) {
    return difference.inDays == 1
        ? 'Updated 1 day ago'
        : 'Updated ${difference.inDays} days ago';
  }
  if (difference.inDays < 30) {
    final weeks = difference.inDays ~/ 7;
    return weeks == 1 ? 'Updated 1 week ago' : 'Updated $weeks weeks ago';
  }
  final months = difference.inDays ~/ 30;
  return months == 1 ? 'Updated 1 month ago' : 'Updated $months months ago';
}
