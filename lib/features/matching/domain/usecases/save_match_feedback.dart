import '../entities/match_feedback_action.dart';
import '../repositories/matching_feedback_repository.dart';
import '../../../../core/result/result.dart';

class SaveMatchFeedback {
  const SaveMatchFeedback(this._repository);

  final MatchingFeedbackRepository _repository;

  Future<Result<MatchFeedbackAction?>> call({
    required String projectId,
    required MatchFeedbackAction action,
    String? promptVersion,
  }) {
    return _repository.saveFeedback(
      projectId: projectId,
      action: action,
      promptVersion: promptVersion,
    );
  }

  Future<Result<void>> clear({required String projectId}) {
    return _repository.clearFeedback(projectId: projectId);
  }
}
