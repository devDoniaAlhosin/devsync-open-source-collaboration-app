import '../../../../core/result/result.dart';
import '../entities/app_user.dart';

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

  Future<Result<void>> signInWithGitHub();

  Future<Result<void>> signOut();

  Future<Result<void>> deleteAccount();

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
