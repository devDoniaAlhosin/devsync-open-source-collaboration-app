import '../entities/matching_analytics.dart';
import '../repositories/matching_repository.dart';

/// Use case for fetching AI model transparency metrics and relevance trends.
class GetMatchingAnalyticsUseCase {
  const GetMatchingAnalyticsUseCase(this._repository);

  final MatchingRepository _repository;

  Future<MatchingAnalytics> call() {
    return _repository.getMatchingAnalytics();
  }
}
