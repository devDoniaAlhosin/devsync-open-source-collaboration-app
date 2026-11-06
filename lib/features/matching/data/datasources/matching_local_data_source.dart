import '../models/match_item_model.dart';

/// Explicit storage of previously fetched backend results, keyed by user.
abstract class MatchingLocalDataSource {
  /// Return cached matches for [uid], newest first.
  Future<List<MatchItemModel>> getCachedMatches(String uid);

  /// Store [matches] in the cache for [uid].
  Future<void> cacheMatches(String uid, List<MatchItemModel> matches);

  /// Clear the cache for [uid] (e.g. on sign-out or account deletion).
  Future<void> clearCache(String uid);
}

/// Session cache. It is never substituted for an API failure.
class InMemoryMatchingLocalDataSource implements MatchingLocalDataSource {
  final Map<String, List<MatchItemModel>> _store = {};

  @override
  Future<List<MatchItemModel>> getCachedMatches(String uid) async {
    return List.unmodifiable(_store[uid] ?? const []);
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
