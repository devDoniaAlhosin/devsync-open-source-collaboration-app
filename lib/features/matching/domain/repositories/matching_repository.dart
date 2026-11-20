import '../../../profile/domain/entities/profile.dart';
import '../../data/models/match_request_model.dart';
import '../entities/match_item.dart';
import '../entities/user_profile.dart';

abstract class MatchingRepository {
  Future<List<MatchItem>> getRankedMatches(
    UserProfile profile, {
    String? prompt,
    Set<String>? tags,
    Profile? userProfile,
    List<CandidateProject>? candidateProjects,
  });

  String? get promptVersion => null;

  Future<List<MatchItem>> getCachedMatches(String uid);

  Future<void> cacheMatches(String uid, List<MatchItem> matches);

  void dispose() {}
}
