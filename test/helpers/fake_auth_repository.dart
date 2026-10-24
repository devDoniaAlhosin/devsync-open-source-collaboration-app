import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/entities/app_user.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.signInResult = const Success(null),
    this.registerResult = const Success(null),
    this.deleteResult = const Success(null),
    this.resetResult = const Success(null),
    Stream<AppUser?>? authState,
  }) : authState = authState ?? Stream<AppUser?>.value(null);

  Result<void> signInResult;
  Result<void> registerResult;
  Result<void> deleteResult;
  Result<void> resetResult;
  final Stream<AppUser?> authState;
  AppUser? user;
  int signOutCalls = 0;
  int deleteCalls = 0;
  int resetCalls = 0;

  @override
  Stream<AppUser?> watchAuthState() => authState;

  @override
  AppUser? get currentUser => user;

  @override
  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  }) async => signInResult;

  @override
  Future<Result<void>> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async => registerResult;

  @override
  Future<Result<void>> signInWithGoogle() async => signInResult;

  @override
  Future<Result<void>> signInWithGitHub() async => signInResult;

  @override
  Future<Result<void>> signOut() async {
    signOutCalls++;
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    deleteCalls++;
    return deleteResult;
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    resetCalls++;
    return resetResult;
  }

  @override
  Future<Result<void>> sendSignInLinkToEmail(String email) async =>
      const Success(null);

  @override
  Future<Result<void>> completeSignInWithEmailLink(String link) async =>
      const Success(null);

  @override
  bool isSignInWithEmailLink(String link) => false;

  @override
  Future<Result<void>> sendEmailVerification() async => const Success(null);

  @override
  Future<Result<bool>> reloadAndIsEmailVerified() async => const Success(true);

  @override
  Future<String?> pendingEmailLinkAddress() async => null;
}
