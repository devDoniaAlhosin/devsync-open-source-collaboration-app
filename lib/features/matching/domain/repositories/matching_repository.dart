import '../entities/match_item.dart';
import '../entities/user_profile.dart';

/// Contract for fetching AI-ranked matches.
///
/// The data layer provides the concrete implementation (Cloud Function +
/// Firestore cache + skills fallback). The domain and presentation layers
/// depend only on this interface.
abstract class MatchingRepository {
  /// Fetch ranked matches for the given [profile].
  ///
  /// Returns a list of [MatchItem] sorted by score (highest first).
  /// If the Cloud Function fails or times out, implementations should
  /// return a fallback list with [MatchItem.isFallback] set to `true`.
  Future<List<MatchItem>> getRankedMatches(UserProfile profile);

  /// Return cached matches for [uid], or an empty list if nothing is cached.
  Future<List<MatchItem>> getCachedMatches(String uid);

  /// Persist [matches] in the local/Firestore cache for [uid].
  Future<void> cacheMatches(String uid, List<MatchItem> matches);
}
