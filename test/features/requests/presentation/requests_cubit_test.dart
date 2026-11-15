import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/entities/collaboration_request.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/repositories/requests_repository.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/usecases/create_request.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/usecases/get_requests.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/usecases/update_request_status.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/cubit/requests_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeRequestsRepository repository;
  late RequestsCubit cubit;

  setUp(() {
    repository = _FakeRequestsRepository();
    cubit = RequestsCubit(
      getRequests: GetRequests(repository),
      createRequest: CreateRequest(repository),
      updateRequestStatus: UpdateRequestStatus(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test(
    'status failure keeps the loaded requests and exposes an action error',
    () async {
      final request = _request();
      repository.requestsResult = Success([request]);
      await cubit.load();
      repository.statusResult = const FailureResult(
        PermissionFailure('You cannot respond to this request.'),
      );

      final success = await cubit.setStatus(
        'request-1',
        RequestStatus.accepted,
      );

      expect(success, isFalse);
      expect(cubit.state, isA<RequestsLoaded>());
      final state = cubit.state as RequestsLoaded;
      expect(state.items, [request]);
      expect(state.actionError, 'You cannot respond to this request.');
    },
  );

  test(
    'successful response updates the request without losing the list',
    () async {
      final request = _request();
      repository.requestsResult = Success([request]);
      await cubit.load();
      repository.statusResult = Success(
        request.copyWith(status: RequestStatus.accepted),
      );

      final success = await cubit.setStatus(
        'request-1',
        RequestStatus.accepted,
      );

      expect(success, isTrue);
      expect(cubit.state, isA<RequestsLoaded>());
      final state = cubit.state as RequestsLoaded;
      expect(state.items.single.status, RequestStatus.accepted);
    },
  );

  test('request creation failure keeps the loaded list', () async {
    final request = _request();
    repository.requestsResult = Success([request]);
    await cubit.load();
    repository.createResult = const FailureResult(
      ValidationFailure('A pending request already exists.'),
    );

    final result = await cubit.create(_request(id: 'request-2'));

    expect(result, isA<FailureResult<RequestItem>>());
    expect(cubit.state, isA<RequestsLoaded>());
    final state = cubit.state as RequestsLoaded;
    expect(state.items, [request]);
    expect(state.actionError, 'A pending request already exists.');
  });
}

RequestItem _request({String id = 'request-1'}) => RequestItem(
  id: id,
  projectId: 'project-1',
  senderId: 'sender-1',
  ownerId: 'owner-1',
  initials: 'DS',
  title: 'DevSync',
  subtitle: 'Pending',
  status: RequestStatus.pending,
  type: RequestType.sent,
);

class _FakeRequestsRepository implements RequestsRepository {
  Result<List<RequestItem>> requestsResult = const Success([]);
  Result<RequestItem>? createResult;
  Result<RequestItem> statusResult = const FailureResult(UnexpectedFailure());

  @override
  Future<Result<List<RequestItem>>> getRequests() async => requestsResult;

  @override
  Future<Result<RequestItem>> createRequest({
    required RequestItem item,
  }) async => createResult ?? Success(item);

  @override
  Future<Result<RequestItem>> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) async => statusResult;
}
