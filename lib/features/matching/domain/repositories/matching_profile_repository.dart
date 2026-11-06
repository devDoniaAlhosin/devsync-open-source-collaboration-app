import '../../../../core/result/result.dart';
import '../entities/user_profile.dart';

/// Matching-owned access to persisted inputs for the authenticated account.
///
/// This deliberately does not use the sample-backed profile feature.
abstract class MatchingProfileRepository {
  String? get currentUserId;

  Future<Result<UserProfile>> getProfile();

  Future<Result<UserProfile>> updateDeclaredSkills(List<String> skills);
}
