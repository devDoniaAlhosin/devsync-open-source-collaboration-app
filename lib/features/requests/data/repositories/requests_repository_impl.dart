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
  Future<Result<RequestItem>> createRequest({required RequestItem item}) async {
    try {
      return Success(await _local.createRequest(item: item));
    } on ArgumentError catch (error) {
      return FailureResult(
        ValidationFailure(error.message?.toString() ?? 'Invalid request'),
      );
    } on StateError catch (error) {
      return FailureResult(ValidationFailure(error.message));
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  @override
  Future<Result<RequestItem>> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    try {
      return Success(
        await _local.updateStatus(requestId: requestId, status: status),
      );
    } on StateError catch (e) {
      return FailureResult(NotFoundFailure(e.message));
    } on ArgumentError catch (e) {
      return FailureResult(
        ValidationFailure(e.message?.toString() ?? 'Invalid status'),
      );
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }
}
