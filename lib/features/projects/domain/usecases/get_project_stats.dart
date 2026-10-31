import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/project_stats.dart';
import '../repositories/projects_repository.dart';

class GetProjectStatsParams {
  const GetProjectStatsParams(this.projectId);

  final String projectId;
}

class GetProjectStats extends UseCase<ProjectStats, GetProjectStatsParams> {
  GetProjectStats(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<ProjectStats>> call(GetProjectStatsParams params) {
    return _repository.getStats(params.projectId);
  }
}
