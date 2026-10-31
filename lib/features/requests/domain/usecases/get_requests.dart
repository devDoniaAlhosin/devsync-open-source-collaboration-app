import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/collaboration_request.dart';
import '../repositories/requests_repository.dart';

class GetRequests extends UseCase<List<RequestItem>, NoParams> {
  GetRequests(this._repository);

  final RequestsRepository _repository;

  @override
  Future<Result<List<RequestItem>>> call(NoParams params) {
    return _repository.getRequests();
  }
}
