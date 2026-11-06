import 'package:firebase_auth/firebase_auth.dart';

/// Provides Firebase ID tokens for API calls.
abstract class AuthTokenProvider {
  Future<String?> getIdToken({bool forceRefresh = false});
}

/// Firebase Auth implementation of [AuthTokenProvider].
class FirebaseAuthTokenProvider implements AuthTokenProvider {
  FirebaseAuthTokenProvider(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return await user.getIdToken(forceRefresh);
    } on FirebaseAuthException catch (e) {
      throw AuthTokenException(
        'Failed to get ID token: ${e.message ?? e.code}',
      );
    } catch (e) {
      throw AuthTokenException('Unexpected error getting ID token: $e');
    }
  }
}

/// Thrown when ID token retrieval fails.
class AuthTokenException implements Exception {
  const AuthTokenException(this.message);

  final String message;

  @override
  String toString() => message;
}
