import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/match_feedback_action.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/repositories/matching_feedback_repository.dart';

class FakeMatchingFeedbackRepository implements MatchingFeedbackRepository {
  final List<(String, MatchFeedbackAction)> savedFeedback = [];
  final List<String> clearedFeedback = [];
  final Map<String, MatchFeedbackAction> _currentFeedback = {};
  Result<void> result = const Success(null);

  @override
  Future<Result<MatchFeedbackAction?>> saveFeedback({
    required String projectId,
    required MatchFeedbackAction action,
    String? promptVersion,
  }) async {
    switch (result) {
      case Success<void>():
        final previous = _currentFeedback[projectId];
        _currentFeedback[projectId] = action;
        savedFeedback.add((projectId, action));
        return Success(previous);
      case FailureResult<void>(:final failure):
        return FailureResult(failure);
    }
  }

  @override
  Future<Result<void>> clearFeedback({required String projectId}) async {
    if (result case Success<void>()) {
      _currentFeedback.remove(projectId);
      clearedFeedback.add(projectId);
    }
    return result;
  }
}
