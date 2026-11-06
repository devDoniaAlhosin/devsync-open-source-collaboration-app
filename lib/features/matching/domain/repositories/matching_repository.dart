import '../entities/match_item.dart';
import '../entities/user_profile.dart';

/// Repository contract for fetching and caching match recommendations.
abstract class MatchingRepository {
  Future<List<MatchItem>> getRankedMatches(
    UserProfile profile, {
    String? prompt,
    Set<String>? tags,
  });

  String? get promptVersion => null;

  Future<List<MatchItem>> getCachedMatches(String uid);

  Future<void> cacheMatches(String uid, List<MatchItem> matches);

  void dispose() {}
}
