import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/notifications/data/datasources/notify_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/data/datasources/requests_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/entities/collaboration_request.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNotify extends Fake implements NotifyRemoteDataSource {
  final events = <({String requestId, String event})>[];

  @override
  Future<void> notifyRequestEvent({
    required String requestId,
    required String event,
  }) async {
    events.add((requestId: requestId, event: event));
  }
}

class _FakeRemote extends Fake implements RequestsRemoteDataSource {
  RequestItem? created;
  RequestItem? updated;
  RequestStatus? lastStatus;

  @override
  Future<RequestItem> createRequest({required RequestItem item}) async {
    created = item.copyWith(id: 'req-1', status: RequestStatus.pending);
    return created!;
  }

  @override
  Future<RequestItem> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    lastStatus = status;
    updated = RequestItem(
      id: requestId,
      projectId: 'p1',
      ownerId: 'owner',
      initials: 'CH',
      title: 'Charts',
      subtitle: status.name,
      status: status,
      type: RequestType.received,
      targetName: 'Charts',
    );
    return updated!;
  }
}

void main() {
  late _FakeNotify notify;
  late _FakeRemote remote;
  late RequestsRepositoryImpl repository;

  setUp(() {
    notify = _FakeNotify();
    remote = _FakeRemote();
    repository = RequestsRepositoryImpl(
      remoteDataSource: remote,
      notifyRemoteDataSource: notify,
    );
  });

  test('createRequest notifies request_received', () async {
    final result = await repository.createRequest(
      item: const RequestItem(
        projectId: 'p1',
        ownerId: 'owner',
        initials: 'CH',
        title: 'Charts',
        subtitle: 'Pending',
        status: RequestStatus.pending,
        type: RequestType.sent,
        targetName: 'Charts',
      ),
    );

    expect(result, isA<Success<RequestItem>>());
    await Future<void>.delayed(Duration.zero);
    expect(notify.events, [
      (requestId: 'req-1', event: 'request_received'),
    ]);
  });

  test('accept notifies request_accepted', () async {
    final result = await repository.updateStatus(
      requestId: 'req-1',
      status: RequestStatus.accepted,
    );

    expect(result, isA<Success<RequestItem>>());
    await Future<void>.delayed(Duration.zero);
    expect(notify.events, [
      (requestId: 'req-1', event: 'request_accepted'),
    ]);
  });

  test('decline notifies request_declined', () async {
    final result = await repository.updateStatus(
      requestId: 'req-1',
      status: RequestStatus.declined,
    );

    expect(result, isA<Success<RequestItem>>());
    await Future<void>.delayed(Duration.zero);
    expect(notify.events, [
      (requestId: 'req-1', event: 'request_declined'),
    ]);
  });
}
