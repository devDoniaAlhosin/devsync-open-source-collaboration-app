import '../../../../core/result/result.dart';
import '../entities/app_user.dart';

/// Device-code UI callback. `true` = continue, `false` = cancel.
typedef GitHubDeviceCodeHandler =
    Future<bool> Function(String userCode, Uri verificationUri);

abstract class AuthRepository {
  Stream<AppUser?> watchAuthState();

  AppUser? get currentUser;

  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<void>> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Result<void>> signInWithGoogle();

  Future<Result<void>> signInWithGitHub({
    GitHubDeviceCodeHandler? onDeviceCode,
  });

  Future<Result<void>> signOut();

  /// Pass [password] for email accounts; Google/GitHub reauth runs in data.
  Future<Result<void>> deleteAccount({String? password});

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> sendEmailOtp(
    String email, {
    String purpose = 'verify',
  });

  Future<Result<void>> verifyOtp({
    required String email,
    required String code,
    String purpose = 'verify',
  });

  Future<Result<void>> resetPasswordWithOtp({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<Result<void>> confirmEmailWithOtp({
    required String email,
    required String code,
  });

  Future<Result<void>> signInWithEmailOtp({
    required String email,
    required String code,
  });
}
