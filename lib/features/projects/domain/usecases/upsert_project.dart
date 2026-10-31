import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/project.dart';
import '../repositories/projects_repository.dart';

class UpsertProject extends UseCase<Project, Project> {
  UpsertProject(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<Project>> call(Project params) {
    return _repository.upsert(params);
  }
}
