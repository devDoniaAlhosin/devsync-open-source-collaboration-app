import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/collaboration_request.dart';
import '../repositories/requests_repository.dart';

class CreateRequestParams {
  const CreateRequestParams({required this.item});

  final RequestItem item;
}

class CreateRequest extends UseCase<RequestItem, CreateRequestParams> {
  CreateRequest(this._repository);

  final RequestsRepository _repository;

  @override
  Future<Result<RequestItem>> call(CreateRequestParams params) {
    return _repository.createRequest(item: params.item);
  }
}
