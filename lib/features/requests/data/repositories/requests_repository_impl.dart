import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../notifications/data/datasources/notify_remote_data_source.dart';
import '../../domain/entities/collaboration_request.dart';
import '../../domain/repositories/requests_repository.dart';
import '../datasources/requests_remote_data_source.dart';

class RequestsRepositoryImpl implements RequestsRepository {
  RequestsRepositoryImpl({
    required RequestsRemoteDataSource remoteDataSource,
    NotifyRemoteDataSource? notifyRemoteDataSource,
  }) : _remote = remoteDataSource,
       _notify = notifyRemoteDataSource;

  final RequestsRemoteDataSource _remote;
  final NotifyRemoteDataSource? _notify;

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
  Future<Result<Set<String>>> getUnavailableProjectIds() async {
    try {
      return Success(await _remote.fetchUnavailableProjectIds());
    } on FirebaseException catch (e) {
      return _firebaseFailure(e);
    } catch (_) {
      return const FailureResult(UnexpectedFailure());
    }
  }

  @override
  Future<Result<RequestItem>> createRequest({required RequestItem item}) async {
    try {
      final created = await _remote.createRequest(item: item);
      // Best-effort FCM + inbox for the project owner.
      unawaitedNotify(
        requestId: created.id,
        event: 'request_received',
      );
      return Success(created);
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
      final updated = await _remote.updateStatus(
        requestId: requestId,
        status: status,
      );
      if (status == RequestStatus.accepted) {
        unawaitedNotify(
          requestId: requestId,
          event: 'request_accepted',
        );
      }
      return Success(updated);
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

  void unawaitedNotify({
    required String requestId,
    required String event,
  }) {
    final notify = _notify;
    if (notify == null) return;
    unawaited(
      notify.notifyRequestEvent(requestId: requestId, event: event).onError(
        (_, _) {},
      ),
    );
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
