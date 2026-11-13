import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/collaboration_request.dart';
import '../../domain/repositories/requests_repository.dart';
// import '../datasources/requests_local_data_source.dart';
import '../datasources/requests_remote_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestsRepositoryImpl implements RequestsRepository {
  RequestsRepositoryImpl({required RequestsRemoteDataSource remoteDataSource})
    : _remote = remoteDataSource;

  final RequestsRemoteDataSource _remote;

  @override
  Future<Result<List<RequestItem>>> getRequests() async {
    try {
      return Success(await _remote.fetchRequests());
    } on FirebaseException catch (e) {
      return _firebaseFailure(e);
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  @override
  Future<Result<RequestItem>> createRequest({required RequestItem item}) async {
    try {
      return Success(await _remote.createRequest(item: item));
    } on ArgumentError catch (error) {
      return FailureResult(
        ValidationFailure(error.message?.toString() ?? 'Invalid request'),
      );
    } on StateError catch (error) {
      return FailureResult(ValidationFailure(error.message));
    } on FirebaseException catch (el) {
      return _firebaseFailure(el);
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
        await _remote.updateStatus(requestId: requestId, status: status),
      );
    } on StateError catch (e) {
      return FailureResult(NotFoundFailure(e.message));
    } on ArgumentError catch (e) {
      return FailureResult(
        ValidationFailure(e.message?.toString() ?? 'Invalid status'),
      );
    } on FirebaseException catch (e) {
      return _firebaseFailure(e);
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  FailureResult<T> _firebaseFailure<T>(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const FailureResult(PermissionFailure());
      case 'unavailable':
      case 'deadline-exceeded':
        return const FailureResult(NetworkFailure());
      case 'not-found':
        return const FailureResult(NotFoundFailure());
      default:
        return const FailureResult(UnexpectedFailure());
    }
  }
}
