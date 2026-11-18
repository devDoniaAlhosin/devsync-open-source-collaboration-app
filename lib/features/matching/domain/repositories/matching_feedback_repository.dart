import '../../../../core/result/result.dart';
import '../entities/match_feedback_action.dart';

abstract class MatchingFeedbackRepository {
  Future<Result<MatchFeedbackAction?>> saveFeedback({
    required String projectId,
    required MatchFeedbackAction action,
  });

  Future<Result<void>> clearFeedback({required String projectId});
}
