import '../../../../core/result/result.dart';
import '../entities/user_profile.dart';

abstract class MatchingProfileRepository {
  String? get currentUserId;

  Future<Result<UserProfile>> getProfile();

  Future<Result<UserProfile>> updateDeclaredSkills(List<String> skills);
}
