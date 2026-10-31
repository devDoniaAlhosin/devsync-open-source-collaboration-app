import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/project.dart';
import '../repositories/projects_repository.dart';

class GetProjects extends UseCase<List<Project>, NoParams> {
  GetProjects(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<List<Project>>> call(NoParams params) {
    return _repository.getProjects();
  }
}
