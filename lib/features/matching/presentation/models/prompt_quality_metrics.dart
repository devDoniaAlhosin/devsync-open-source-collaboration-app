import 'package:flutter/foundation.dart';

@immutable
class PromptQualityVersion {
  const PromptQualityVersion({required this.label, required this.relevance})
    : assert(relevance >= 0 && relevance <= 100);

  final String label;
  final double relevance;
}

/// A presentation snapshot supplied by the analytics source.
@immutable
class PromptQualityMetrics {
  PromptQualityMetrics({
    required List<PromptQualityVersion> versions,
    required this.averageMatchTime,
    required this.timelyAlertsPercentage,
    this.relevanceTarget = 50,
    this.improvementTarget = 15,
  }) : assert(relevanceTarget >= 0 && relevanceTarget <= 100),
       assert(timelyAlertsPercentage >= 0 && timelyAlertsPercentage <= 100),
       versions = List.unmodifiable(versions);

  final List<PromptQualityVersion> versions;
  final Duration averageMatchTime;
  final double timelyAlertsPercentage;
  final double relevanceTarget;
  final double improvementTarget;

  double? get latestRelevance => versions.lastOrNull?.relevance;

  double? get improvementPercentage {
    if (versions.length < 2 || versions.first.relevance == 0) return null;
    return (versions.last.relevance / versions.first.relevance - 1) * 100;
  }

  static final demo = PromptQualityMetrics(
    versions: const [
      PromptQualityVersion(label: 'v1', relevance: 48),
      PromptQualityVersion(label: 'v2', relevance: 57),
      PromptQualityVersion(label: 'v3', relevance: 64),
    ],
    averageMatchTime: const Duration(seconds: 2),
    timelyAlertsPercentage: 98,
  );
}
