import '../../../../core/result/result.dart';
import '../entities/feedback_record.dart';

abstract class FeedbackRepository {
  Future<Result<List<FeedbackRecord>>> getUserFeedback();
}
