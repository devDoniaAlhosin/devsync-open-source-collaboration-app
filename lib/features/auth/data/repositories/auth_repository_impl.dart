import '../../../../core/result/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../mappers/auth_failure_mapper.dart';
import '../models/app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  AppUser? _mapUser() {
    final user = _remote.currentUser;
    if (user == null) return null;
    return AppUserModel.fromFirebaseUser(user);
  }

  Future<Result<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Success(null);
    } catch (error) {
      return FailureResult(mapAuthError(error));
    }
  }

  @override
  Stream<AppUser?> watchAuthState() {
    return _remote.authStateChanges.map((user) {
      if (user == null) return null;
      return AppUserModel.fromFirebaseUser(user);
    });
  }

  @override
  AppUser? get currentUser => _mapUser();

  @override
  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(
      () => _remote.signInWithEmail(email: email, password: password),
    );
  }

  @override
  Future<Result<void>> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _guard(
      () => _remote.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  @override
  Future<Result<void>> signInWithGoogle() => _guard(_remote.signInWithGoogle);

  @override
  Future<Result<void>> signInWithGitHub() => _guard(_remote.signInWithGitHub);

  @override
  Future<Result<void>> signOut() => _guard(_remote.signOut);

  @override
  Future<Result<void>> sendSignInLinkToEmail(String email) {
    return _guard(() => _remote.sendSignInLinkToEmail(email));
  }

  @override
  Future<Result<void>> completeSignInWithEmailLink(String link) {
    return _guard(() async {
      await _remote.completeSignInWithEmailLink(link);
    });
  }

  @override
  bool isSignInWithEmailLink(String link) =>
      _remote.isSignInWithEmailLink(link);

  @override
  Future<Result<void>> sendEmailVerification() {
    return _guard(_remote.sendEmailVerification);
  }

  @override
  Future<Result<bool>> reloadAndIsEmailVerified() async {
    try {
      final verified = await _remote.reloadAndIsEmailVerified();
      return Success(verified);
    } catch (error) {
      return FailureResult(mapAuthError(error));
    }
  }

  @override
  Future<String?> pendingEmailLinkAddress() {
    return _remote.pendingEmailLinkAddress();
  }
}
