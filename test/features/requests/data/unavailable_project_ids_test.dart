import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/core/usecase/usecase.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/data/datasources/requests_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/entities/collaboration_request.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/repositories/requests_repository.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/usecases/get_unavailable_project_ids.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RequestsRemoteDataSource.unavailableProjectIdsFrom', () {
    test('keeps pending, isNew, and accepted project IDs', () {
      final ids = RequestsRemoteDataSource.unavailableProjectIdsFrom([
        {'projectId': 'p-pending', 'status': 'pending'},
        {'projectId': 'p-new', 'status': 'isNew'},
        {'projectId': 'p-accepted', 'status': 'accepted'},
        {'projectId': 'p-declined', 'status': 'declined'},
        {'projectId': '  ', 'status': 'pending'},
        {'status': 'accepted'},
      ]);

      expect(ids, {'p-pending', 'p-new', 'p-accepted'});
    });
  });

  group('GetUnavailableProjectIds', () {
    test('returns repository set', () async {
      final repository = _FakeRequestsRepository()
        ..unavailableResult = const Success({'proj-a', 'proj-b'});
      final useCase = GetUnavailableProjectIds(repository);

      final result = await useCase(const NoParams());

      expect(
        result.fold((_) => <String>{}, (ids) => ids),
        {'proj-a', 'proj-b'},
      );
    });
  });
}

class _FakeRequestsRepository implements RequestsRepository {
  Result<Set<String>> unavailableResult = const Success(<String>{});

  @override
  Future<Result<List<RequestItem>>> getRequests() async => const Success([]);

  @override
  Future<Result<Set<String>>> getUnavailableProjectIds() async =>
      unavailableResult;

  @override
  Future<Result<RequestItem>> createRequest({
    required RequestItem item,
  }) async => const FailureResult(UnexpectedFailure());

  @override
  Future<Result<RequestItem>> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) async => const FailureResult(UnexpectedFailure());

  @override
  Stream<bool> watchHasPendingReceived() => Stream.value(false);
}
