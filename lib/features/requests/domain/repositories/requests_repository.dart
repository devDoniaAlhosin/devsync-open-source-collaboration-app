import '../../../../core/result/result.dart';
import '../entities/collaboration_request.dart';

abstract class RequestsRepository {
  Future<Result<List<RequestItem>>> getRequests();

  /// Project IDs the signed-in user already requested and cannot request again
  /// (`pending`, `isNew`, or `accepted`).
  Future<Result<Set<String>>> getUnavailableProjectIds();

  Future<Result<RequestItem>> createRequest({required RequestItem item});

  Future<Result<RequestItem>> updateStatus({
    required RequestStatus status,
    required String requestId,
  });
}
