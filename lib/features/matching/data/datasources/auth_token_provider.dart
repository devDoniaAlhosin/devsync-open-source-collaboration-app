import 'package:firebase_auth/firebase_auth.dart';

/// Provides Firebase ID tokens for authenticated API requests.
///
/// This abstraction allows the matching data layer to obtain auth tokens
/// without directly depending on FirebaseAuth implementation details,
/// following the Dependency Inversion Principle.
abstract class AuthTokenProvider {
  /// Get the current user's Firebase ID token.
  ///
  /// Returns null if no user is signed in.
  /// Throws [AuthTokenException] if token retrieval fails.
  Future<String?> getIdToken({bool forceRefresh = false});
}

/// Firebase implementation of [AuthTokenProvider].
///
/// Retrieves ID tokens from the current Firebase Auth session.
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

/// Exception thrown when ID token retrieval fails.
class AuthTokenException implements Exception {
  const AuthTokenException(this.message);

  final String message;

  @override
  String toString() => message;
}
