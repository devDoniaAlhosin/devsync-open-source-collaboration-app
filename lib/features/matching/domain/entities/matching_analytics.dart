import 'package:equatable/equatable.dart';

/// Aggregated metrics from user feedback for matching recommendations.
class MatchingAnalytics extends Equatable {
  const MatchingAnalytics({
    required this.ratedCount,
    this.positivePercentage,
    this.trendValues = const [],
    this.skillsMatchedCount,
  });

  /// Total number of matches rated by the user.
  final int ratedCount;

  /// Percentage of ratings that were positive (likes ÷ rated * 100).
  /// Null if [ratedCount] == 0.
  final int? positivePercentage;

  /// Daily positive percentage trend (chronologically ascending).
  /// Requires at least 2 distinct days to be considered meaningful.
  final List<double> trendValues;

  /// Unique skills matched between the user's declared skills and liked projects.
  /// Null if not computable (e.g. no project skills available).
  final int? skillsMatchedCount;

  bool get isEmpty => ratedCount == 0;
  bool get hasEnoughTrendData => trendValues.length >= 2;

  static const empty = MatchingAnalytics(
    ratedCount: 0,
    positivePercentage: null,
    trendValues: [],
    skillsMatchedCount: null,
  );

  @override
  List<Object?> get props => [
    ratedCount,
    positivePercentage,
    trendValues,
    skillsMatchedCount,
  ];
}
