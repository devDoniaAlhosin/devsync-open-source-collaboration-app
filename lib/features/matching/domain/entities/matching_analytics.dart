import 'package:equatable/equatable.dart';

class MatchingAnalytics extends Equatable {
  const MatchingAnalytics({
    required this.ratedCount,
    this.positivePercentage,
    this.trendValues = const [],
    this.skillsMatchedCount,
  });

  final int ratedCount;

  final int? positivePercentage;

  final List<double> trendValues;

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
