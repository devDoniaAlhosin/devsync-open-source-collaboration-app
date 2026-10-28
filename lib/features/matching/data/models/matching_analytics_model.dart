import '../../domain/entities/matching_analytics.dart';

/// Data layer model for recommendation metrics and transparency insights.
class MatchingAnalyticsModel extends MatchingAnalytics {
  const MatchingAnalyticsModel({
    required super.matchesRated,
    required super.positiveSignalsPercentage,
    required super.skillsMatchedCount,
    required super.relevanceTrend,
    required super.scoringBreakdown,
  });

  factory MatchingAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return MatchingAnalyticsModel(
      matchesRated: json['matchesRated'] as int? ?? 18,
      positiveSignalsPercentage:
          json['positiveSignalsPercentage'] as int? ?? 83,
      skillsMatchedCount: json['skillsMatchedCount'] as int? ?? 4,
      relevanceTrend:
          (json['relevanceTrend'] as List? ??
                  [43.0, 59.0, 68.0, 65.0, 87.0, 100.0, 111.0])
              .map((e) => (e as num).toDouble())
              .toList(),
      scoringBreakdown: Map<String, int>.from(
        json['scoringBreakdown'] as Map? ??
            {'Skills': 90, 'Activity': 75, 'Interests': 85},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchesRated': matchesRated,
      'positiveSignalsPercentage': positiveSignalsPercentage,
      'skillsMatchedCount': skillsMatchedCount,
      'relevanceTrend': relevanceTrend,
      'scoringBreakdown': scoringBreakdown,
    };
  }

  factory MatchingAnalyticsModel.fromEntity(MatchingAnalytics entity) {
    return MatchingAnalyticsModel(
      matchesRated: entity.matchesRated,
      positiveSignalsPercentage: entity.positiveSignalsPercentage,
      skillsMatchedCount: entity.skillsMatchedCount,
      relevanceTrend: entity.relevanceTrend,
      scoringBreakdown: entity.scoringBreakdown,
    );
  }
}
