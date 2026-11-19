import '../../../../core/result/result.dart';
import '../entities/feedback_record.dart';
import '../repositories/feedback_repository.dart';

/// Returns the current user's feedback records, deduplicated by project.
///
/// Sorted descending by timestamp; latest doc per projectId wins.
/// Zero feedback → empty list (not a failure).
class GetUserFeedbackUseCase {
  const GetUserFeedbackUseCase(this._repository);

  final FeedbackRepository _repository;

  Future<Result<List<FeedbackRecord>>> call() async {
    final result = await _repository.getUserFeedback();
    return result.fold(FailureResult.new, (records) {
      // Sort descending by timestamp (nulls last), then deduplicate by
      // projectId keeping the latest record per project.
      final sorted = [...records]
        ..sort((a, b) {
          final ta = a.timestamp;
          final tb = b.timestamp;
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });

      final seen = <String>{};
      final deduped = <FeedbackRecord>[];
      for (final record in sorted) {
        if (seen.add(record.projectId)) {
          deduped.add(record);
        }
      }
      return Success(deduped);
    });
  }
}
