import '../domain/entities/match_item.dart';

/// Current-session display cache; Firestore stores the durable feedback.
class LikedMatchesStore {
  LikedMatchesStore._();

  static final LikedMatchesStore instance = LikedMatchesStore._();

  final List<MatchItem> _items = [];

  List<MatchItem> get items => List.unmodifiable(_items);

  void add(MatchItem match) {
    if (_items.any((m) => m.projectId == match.projectId)) return;
    _items.insert(0, match);
  }

  void remove(String projectId) {
    _items.removeWhere((match) => match.projectId == projectId);
  }
}
