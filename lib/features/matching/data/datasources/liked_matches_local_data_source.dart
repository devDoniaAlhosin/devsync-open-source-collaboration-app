import '../../domain/entities/match_item.dart';

/// Local data source for managing liked/hearted matches.
///
/// In-memory storage until Firestore persistence is implemented.
/// This is a singleton data source accessed across the feature.
abstract class LikedMatchesLocalDataSource {
  /// Get all liked matches.
  List<MatchItem> getLikedMatches();

  /// Add a match to liked list if not already present.
  void addLikedMatch(MatchItem match);

  /// Remove a match from liked list.
  void removeLikedMatch(String projectId);

  /// Clear all liked matches.
  void clearLikedMatches();
}

/// In-memory implementation of liked matches storage.
class InMemoryLikedMatchesDataSource implements LikedMatchesLocalDataSource {
  InMemoryLikedMatchesDataSource._();

  static final InMemoryLikedMatchesDataSource instance =
      InMemoryLikedMatchesDataSource._();

  final List<MatchItem> _items = [];

  @override
  List<MatchItem> getLikedMatches() => List.unmodifiable(_items);

  @override
  void addLikedMatch(MatchItem match) {
    if (_items.any((m) => m.projectId == match.projectId)) return;
    _items.insert(0, match);
  }

  @override
  void removeLikedMatch(String projectId) {
    _items.removeWhere((m) => m.projectId == projectId);
  }

  @override
  void clearLikedMatches() {
    _items.clear();
  }
}
