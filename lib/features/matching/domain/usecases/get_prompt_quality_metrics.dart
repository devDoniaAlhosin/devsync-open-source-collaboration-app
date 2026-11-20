import '../../../../core/result/result.dart';
import '../entities/prompt_quality_metrics.dart';
import '../repositories/feedback_repository.dart';
import '../utils/prompt_quality_aggregator.dart';

class GetPromptQualityMetrics {
  const GetPromptQualityMetrics(this._repository);

  final FeedbackRepository _repository;

  Future<Result<PromptQualityMetrics?>> call() async {
    final result = await _repository.getUserFeedback();
    return result.fold(FailureResult.new, (records) {
      return Success(PromptQualityAggregator.aggregate(records));
    });
  }
}
