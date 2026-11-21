import '../entities/feedback_record.dart';
import '../entities/prompt_quality_metrics.dart';

class PromptQualityAggregator {
  const PromptQualityAggregator._();

  /// Relevance = likes / (likes + skips) per [FeedbackRecord.promptVersion].
  /// Records without a version are ignored.
  static PromptQualityMetrics? aggregate(List<FeedbackRecord> feedback) {
    final byVersion = <String, _Counts>{};

    for (final record in feedback) {
      final version = record.promptVersion?.trim();
      if (version == null || version.isEmpty) continue;
      if (!record.isLike && !record.isSkip) continue;

      final counts = byVersion.putIfAbsent(version, _Counts.new);
      if (record.isLike) {
        counts.likes += 1;
      } else {
        counts.skips += 1;
      }
    }

    if (byVersion.isEmpty) return null;

    final versions =
        byVersion.entries.map((entry) {
            final total = entry.value.likes + entry.value.skips;
            final relevance = total == 0
                ? 0.0
                : (entry.value.likes / total) * 100;
            return PromptQualityVersion(label: entry.key, relevance: relevance);
          }).toList()
          ..sort((a, b) => a.label.compareTo(b.label));

    return PromptQualityMetrics(versions: versions);
  }
}

class _Counts {
  int likes = 0;
  int skips = 0;
}
