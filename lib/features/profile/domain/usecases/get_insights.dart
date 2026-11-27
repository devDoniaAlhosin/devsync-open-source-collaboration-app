import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/insights_data.dart';
import '../repositories/insights_repository.dart';

class GetInsights extends UseCase<InsightsData, NoParams> {
  GetInsights(this._repository);

  final InsightsRepository _repository;

  @override
  Future<Result<InsightsData>> call(NoParams params) =>
      _repository.getInsights();
}
