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
  Future<Result<void>> deleteAccount() => _guard(_remote.deleteAccount);

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) {
    return _guard(() => _remote.sendPasswordResetEmail(email));
  }

  @override
  Future<Result<void>> sendEmailOtp(
    String email, {
    String purpose = 'verify',
  }) {
    return _guard(() => _remote.sendEmailOtp(email, purpose: purpose));
  }

  @override
  Future<Result<void>> verifyOtp({
    required String email,
    required String code,
    String purpose = 'verify',
  }) {
    return _guard(
      () => _remote.verifyOtp(email: email, code: code, purpose: purpose),
    );
  }

  @override
  Future<Result<void>> resetPasswordWithOtp({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _guard(
      () => _remote.resetPasswordWithOtp(
        email: email,
        code: code,
        newPassword: newPassword,
      ),
    );
  }

  @override
  Future<Result<void>> confirmEmailWithOtp({
    required String email,
    required String code,
  }) {
    return _guard(() => _remote.confirmEmailWithOtp(email: email, code: code));
  }

  @override
  Future<Result<void>> signInWithEmailOtp({
    required String email,
    required String code,
  }) {
    return _guard(
      () => _remote.signInWithEmailOtp(email: email, code: code),
    );
  }
}
