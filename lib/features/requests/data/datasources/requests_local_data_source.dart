import '../../../../core/dummy/dummy_requests.dart';
import '../../domain/entities/collaboration_request.dart';

/// Local / dummy requests source until Firestore + FCM are wired.
class RequestsLocalDataSource {
  RequestsLocalDataSource() : _items = List<RequestItem>.from(requests);

  final List<RequestItem> _items;

  Future<List<RequestItem>> fetchRequests() async =>
      List<RequestItem>.unmodifiable(_items);

  Future<RequestItem> updateStatus({
    required RequestItem item,
    required RequestStatus status,
  }) async {
    final index = _items.indexWhere(
      (r) =>
          r.title == item.title &&
          r.type == item.type &&
          r.displayName == item.displayName,
    );
    if (index < 0) {
      throw StateError('Request not found');
    }
    final updated = RequestItem(
      initials: item.initials,
      title: item.title,
      subtitle: item.subtitle,
      status: status,
      type: item.type,
      message: item.message,
      displayName: item.displayName,
      targetName: item.targetName,
      matchPercent: item.matchPercent,
      matchSummary: item.matchSummary,
      repositoryCount: item.repositoryCount,
      commitCount: item.commitCount,
      languageCount: item.languageCount,
      skills: item.skills,
    );
    _items[index] = updated;
    return updated;
  }
}
