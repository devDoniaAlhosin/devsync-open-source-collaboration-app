import '../../../../core/result/result.dart';
import '../../data/models/insights_data.dart';

abstract class InsightsRepository {
  Future<Result<InsightsData>> getInsights();
}
