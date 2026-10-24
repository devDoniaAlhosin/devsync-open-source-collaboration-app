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

  Future<Result<void>> sendSignInLinkToEmail(String email);

  Future<Result<void>> completeSignInWithEmailLink(String link);

  bool isSignInWithEmailLink(String link);

  Future<Result<void>> sendEmailVerification();

  Future<Result<bool>> reloadAndIsEmailVerified();

  Future<String?> pendingEmailLinkAddress();
}
