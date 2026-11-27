import 'package:equatable/equatable.dart';

class PromptQualityVersion extends Equatable {
  const PromptQualityVersion({required this.label, required this.relevance})
    : assert(relevance >= 0 && relevance <= 100);

  final String label;
  final double relevance;

  @override
  List<Object?> get props => [label, relevance];
}

class PromptQualityMetrics extends Equatable {
  PromptQualityMetrics({
    required List<PromptQualityVersion> versions,
    this.averageMatchTime,
    this.timelyAlertsPercentage,
    this.relevanceTarget = 50,
    this.improvementTarget = 15,
  }) : assert(
         timelyAlertsPercentage == null ||
             (timelyAlertsPercentage >= 0 && timelyAlertsPercentage <= 100),
       ),
       assert(relevanceTarget >= 0 && relevanceTarget <= 100),
       versions = List.unmodifiable(versions);

  final List<PromptQualityVersion> versions;
  final Duration? averageMatchTime;
  final double? timelyAlertsPercentage;
  final double relevanceTarget;
  final double improvementTarget;

  double? get latestRelevance => versions.isEmpty ? null : versions.last.relevance;

  /// Highest-relevance prompt version (for auto-optimize / apply).
  PromptQualityVersion? get bestVersion {
    if (versions.isEmpty) return null;
    return versions.reduce(
      (a, b) => a.relevance >= b.relevance ? a : b,
    );
  }

  double? get improvementPercentage {
    if (versions.length < 2 || versions.first.relevance == 0) return null;
    return (versions.last.relevance / versions.first.relevance - 1) * 100;
  }

  @override
  List<Object?> get props => [
    versions,
    averageMatchTime,
    timelyAlertsPercentage,
    relevanceTarget,
    improvementTarget,
  ];
}
