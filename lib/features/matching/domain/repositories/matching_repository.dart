import '../entities/match_item.dart';
import '../entities/user_profile.dart';

/// Contract for the authenticated matching backend.
abstract class MatchingRepository {
  Future<List<MatchItem>> getRankedMatches(
    UserProfile profile, {
    String? prompt,
    Set<String>? tags,
  });

  /// Backend prompt version for the most recent successful request.
  String? get promptVersion => null;

  /// Return cached matches for [uid], or an empty list if nothing is cached.
  Future<List<MatchItem>> getCachedMatches(String uid);

  /// Persist [matches] in the local/Firestore cache for [uid].
  Future<void> cacheMatches(String uid, List<MatchItem> matches);

  /// Releases resources held by the concrete transport, if any.
  void dispose() {}
}
