/// Model transparency and AI recommendation performance metrics.
class MatchingAnalytics {
  const MatchingAnalytics({
    required this.matchesRated,
    required this.positiveSignalsPercentage,
    required this.skillsMatchedCount,
    required this.relevanceTrend,
    required this.scoringBreakdown,
  });

  /// Total number of matches the user has reviewed / swiped.
  final int matchesRated;

  /// Percentage of positive collaboration actions (likes/requests).
  final int positiveSignalsPercentage;

  /// Count of unique skills matched across recommendations.
  final int skillsMatchedCount;

  /// Historical relevance trend scores (normalized bar heights).
  final List<double> relevanceTrend;

  /// Relative scoring weights (e.g. Skills: 90, Activity: 75, Interests: 85).
  final Map<String, int> scoringBreakdown;

  /// Default demo analytics for transparency views.
  static const MatchingAnalytics demoAnalytics = MatchingAnalytics(
    matchesRated: 18,
    positiveSignalsPercentage: 83,
    skillsMatchedCount: 4,
    relevanceTrend: [43.0, 59.0, 68.0, 65.0, 87.0, 100.0, 111.0],
    scoringBreakdown: {
      'Skills': 90,
      'Activity': 75,
      'Interests': 85,
    },
  );
}
