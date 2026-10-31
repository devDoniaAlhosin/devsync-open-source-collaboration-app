import '../../../../core/result/result.dart';
import '../entities/collaboration_request.dart';

abstract class RequestsRepository {
  Future<Result<List<RequestItem>>> getRequests();

  Future<Result<RequestItem>> updateStatus({
    required RequestItem item,
    required RequestStatus status,
  });
}
