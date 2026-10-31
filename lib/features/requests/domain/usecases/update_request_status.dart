import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/collaboration_request.dart';
import '../repositories/requests_repository.dart';

class UpdateRequestStatusParams {
  const UpdateRequestStatusParams({
    required this.item,
    required this.status,
  });

  final RequestItem item;
  final RequestStatus status;
}

class UpdateRequestStatus
    extends UseCase<RequestItem, UpdateRequestStatusParams> {
  UpdateRequestStatus(this._repository);

  final RequestsRepository _repository;

  @override
  Future<Result<RequestItem>> call(UpdateRequestStatusParams params) {
    return _repository.updateStatus(
      item: params.item,
      status: params.status,
    );
  }
}
