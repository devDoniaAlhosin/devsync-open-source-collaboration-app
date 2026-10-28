import '../entities/match_item.dart';
import '../entities/user_profile.dart';
import '../repositories/matching_repository.dart';

/// Use case for retrieving AI-ranked project matches based on user developer profile.
class GetRankedMatchesUseCase {
  const GetRankedMatchesUseCase(this._repository);

  final MatchingRepository _repository;

  Future<List<MatchItem>> call(UserProfile profile) {
    return _repository.getRankedMatches(profile);
  }
}
