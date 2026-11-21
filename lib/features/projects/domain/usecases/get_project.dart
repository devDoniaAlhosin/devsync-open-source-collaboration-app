import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/project.dart';
import '../repositories/projects_repository.dart';

class GetProjectParams {
  const GetProjectParams(this.projectId);

  final String projectId;
}

class GetProject extends UseCase<Project, GetProjectParams> {
  GetProject(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<Project>> call(GetProjectParams params) {
    return _repository.getProject(params.projectId);
  }
}
