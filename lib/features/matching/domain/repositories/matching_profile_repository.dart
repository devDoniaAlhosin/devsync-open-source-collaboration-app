import '../../../../core/result/result.dart';
import '../entities/user_profile.dart';

/// Contract for accessing user matching profile inputs.
abstract class MatchingProfileRepository {
  String? get currentUserId;

  Future<Result<UserProfile>> getProfile();

  Future<Result<UserProfile>> updateDeclaredSkills(List<String> skills);
}
