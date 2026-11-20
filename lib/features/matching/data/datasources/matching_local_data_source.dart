import '../models/match_item_model.dart';

abstract class MatchingLocalDataSource {
  Future<List<MatchItemModel>> getCachedMatches(String uid);
  Future<void> cacheMatches(String uid, List<MatchItemModel> matches);
  Future<void> clearCache(String uid);
}

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
