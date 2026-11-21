import 'package:equatable/equatable.dart';

class MatchingAnalytics extends Equatable {
  const MatchingAnalytics({
    required this.ratedCount,
    this.positivePercentage,
    this.trendValues = const [],
    this.skillsMatchedCount,
    this.isDemo = false,
  });

  final int ratedCount;

  final int? positivePercentage;

  final List<double> trendValues;

  final int? skillsMatchedCount;

  /// True when this object contains placeholder demo data (not real feedback).
  final bool isDemo;

  bool get isEmpty => ratedCount == 0;
  bool get hasEnoughTrendData => trendValues.length >= 2;

  static const empty = MatchingAnalytics(
    ratedCount: 0,
    positivePercentage: null,
    trendValues: [],
    skillsMatchedCount: null,
  );

  /// Placeholder analytics shown before the user has real feedback data.
  ///
  /// Used as "Data today" per the AI analytics spec — replace with real
  /// Firestore aggregation once feedback collection is wired.
  static const demoAnalytics = MatchingAnalytics(
    ratedCount: 18,
    positivePercentage: 83,
    trendValues: [30, 42, 55, 60, 70, 80, 83],
    skillsMatchedCount: 4,
    isDemo: true,
  );

  @override
  List<Object?> get props => [
    ratedCount,
    positivePercentage,
    trendValues,
    skillsMatchedCount,
    isDemo,
  ];
}
