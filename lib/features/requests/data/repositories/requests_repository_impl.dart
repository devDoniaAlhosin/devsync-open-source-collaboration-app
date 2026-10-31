import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/collaboration_request.dart';
import '../../domain/repositories/requests_repository.dart';
import '../datasources/requests_local_data_source.dart';

class RequestsRepositoryImpl implements RequestsRepository {
  RequestsRepositoryImpl({required RequestsLocalDataSource localDataSource})
    : _local = localDataSource;

  final RequestsLocalDataSource _local;

  @override
  Future<Result<List<RequestItem>>> getRequests() async {
    try {
      return Success(await _local.fetchRequests());
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  @override
  Future<Result<RequestItem>> updateStatus({
    required RequestItem item,
    required RequestStatus status,
  }) async {
    try {
      return Success(
        await _local.updateStatus(item: item, status: status),
      );
    } on StateError {
      return const FailureResult(NotFoundFailure('Request not found'));
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }
}
