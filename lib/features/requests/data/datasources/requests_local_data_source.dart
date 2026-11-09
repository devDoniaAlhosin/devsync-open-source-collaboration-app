import '../../../../core/dummy/dummy_requests.dart';
import '../../domain/entities/collaboration_request.dart';

/// Local / dummy requests source until Firestore + FCM are wired.
class RequestsLocalDataSource {
  // RequestsLocalDataSource() : _items = List<RequestItem>.from(requests);
  RequestsLocalDataSource() : _items = _prepareInitialRequests();
  int _nextId = 1;
  static List<RequestItem> _prepareInitialRequests() {
    return [
      for (var index = 0; index < requests.length; index++)
        requests[index].id.isEmpty
            ? requests[index].copyWith(id: 'demo-request-${index + 1}')
            : requests[index],
    ];
  }

  final List<RequestItem> _items;

  Future<List<RequestItem>> fetchRequests() async =>
      List<RequestItem>.unmodifiable(_items);

  Future<RequestItem> createRequest({required RequestItem item}) async {
    if (item.projectId.isEmpty ||
        item.senderId == null ||
        item.senderId!.isEmpty ||
        item.ownerId == null ||
        item.ownerId!.isEmpty) {
      throw ArgumentError('Project ID, sender ID and owner ID are required.');
    }

    final alreadyExists = _items.any(
      (request) =>
          request.projectId == item.projectId &&
          request.senderId == item.senderId &&
          request.isPending,
    );

    if (alreadyExists) {
      throw StateError('A pending request already exists.');
    }

    final created = item.copyWith(
      id: 'local-request-${_nextId++}',
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
    );

    _items.add(created);
    return created;
  }

  Future<RequestItem> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    final index = _items.indexWhere((request) => request.id == requestId);
    if (index < 0) {
      throw StateError('Request not found');
    }

    final existing = _items[index];
    if (!existing.isPending) throw StateError('Request is no longer pending.');

    if (status != RequestStatus.accepted && status != RequestStatus.declined) {
      throw ArgumentError('Invalid response status.');
    }

    final updated = existing.copyWith(
      status: status,
      respondedAt: DateTime.now(),
    );
    _items[index] = updated;
    return updated;
  }
}
