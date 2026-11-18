import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/projects_repository.dart';

/// Accepted collaborations across the signed-in user's projects.
class GetJoinedContributions extends UseCase<int, NoParams> {
  GetJoinedContributions(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<int>> call(NoParams params) {
    return _repository.getJoinedContributions();
  }
}
