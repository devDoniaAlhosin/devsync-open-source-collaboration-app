import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/projects_repository.dart';

class DeleteProjectParams {
  const DeleteProjectParams(this.projectId);

  final String projectId;
}

class DeleteProject extends UseCase<void, DeleteProjectParams> {
  DeleteProject(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<void>> call(DeleteProjectParams params) {
    return _repository.delete(params.projectId);
  }
}
