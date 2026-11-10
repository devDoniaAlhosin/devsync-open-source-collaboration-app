import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/projects_repository.dart';

class RecordProjectViewParams {
  const RecordProjectViewParams(this.projectId);

  final String projectId;
}

/// Logs a unique daily view when a user opens project details.
class RecordProjectView extends UseCase<void, RecordProjectViewParams> {
  RecordProjectView(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<void>> call(RecordProjectViewParams params) {
    return _repository.recordView(params.projectId);
  }
}
