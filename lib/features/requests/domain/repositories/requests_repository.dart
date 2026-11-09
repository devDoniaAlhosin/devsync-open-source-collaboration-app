import '../../../../core/result/result.dart';
import '../entities/collaboration_request.dart';

abstract class RequestsRepository {
  Future<Result<List<RequestItem>>> getRequests();

  Future<Result<RequestItem>> createRequest({required RequestItem item});

  Future<Result<RequestItem>> updateStatus({
    required RequestStatus status,
    required String requestId,
  });
}
