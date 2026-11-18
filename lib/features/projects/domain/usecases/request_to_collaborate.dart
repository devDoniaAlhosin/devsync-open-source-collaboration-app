import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/collaboration_request_receipt.dart';
import '../entities/project.dart';
import '../repositories/projects_repository.dart';

class RequestToCollaborateParams {
  const RequestToCollaborateParams({required this.project, this.message});

  final Project project;
  final String? message;
}

/// Sends a collaboration request for [RequestToCollaborateParams.project].
class RequestToCollaborate
    extends UseCase<CollaborationRequestReceipt, RequestToCollaborateParams> {
  RequestToCollaborate(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<CollaborationRequestReceipt>> call(
    RequestToCollaborateParams params,
  ) {
    return _repository.requestToCollaborate(
      project: params.project,
      message: params.message,
    );
  }
}
