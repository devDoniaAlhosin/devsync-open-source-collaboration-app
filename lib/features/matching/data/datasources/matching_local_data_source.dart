import '../models/match_item_model.dart';

/// Reads and writes cached match results (Firestore `matches` collection).
///
/// The cache avoids redundant Cloud Function calls and lets the feed
/// show stale data while a refresh runs in the background.
abstract class MatchingLocalDataSource {
  /// Return cached matches for [uid], newest first.
  Future<List<MatchItemModel>> getCachedMatches(String uid);

  /// Store [matches] in the cache for [uid].
  Future<void> cacheMatches(String uid, List<MatchItemModel> matches);

  /// Clear the cache for [uid] (e.g. on sign-out or account deletion).
  Future<void> clearCache(String uid);
}

/// In-memory cache used until Firestore is wired in.
class InMemoryMatchingLocalDataSource implements MatchingLocalDataSource {
  final Map<String, List<MatchItemModel>> _store = {};

  @override
  Future<List<MatchItemModel>> getCachedMatches(String uid) async {
    return _store[uid] ?? [];
  }

  @override
  Future<void> cacheMatches(String uid, List<MatchItemModel> matches) async {
    _store[uid] = List.of(matches);
  }

  @override
  Future<void> clearCache(String uid) async {
    _store.remove(uid);
  }
}
