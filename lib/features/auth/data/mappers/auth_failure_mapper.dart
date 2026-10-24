import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/failures.dart';
import '../../domain/failures/auth_failures.dart';
import '../datasources/auth_remote_data_source.dart';

Failure mapAuthError(Object error) {
  if (error is AuthCancelledException) {
    return const CancelledFailure();
  }
  if (error is EmailNotVerifiedException) {
    return EmailNotVerifiedFailure(email: error.email);
  }
  if (error is GoogleOnlyAccountException) {
    return const AuthFailure(
      'This account uses Google. Continue with Google instead.',
    );
  }
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure('Invalid email or password');
      case 'email-already-in-use':
        return const AuthFailure('An account already exists for that email');
      case 'weak-password':
        return const ValidationFailure(
          'Password is too weak',
          field: 'password',
        );
      case 'invalid-email':
        return const ValidationFailure(
          'Enter a valid email address',
          field: 'email',
        );
      case 'requires-recent-login':
        return const AuthFailure('Sign in again, then delete your account');
      case 'network-request-failed':
        return const NetworkFailure();
      case 'account-exists-with-different-credential':
        return const AuthFailure(
          'An account already exists with a different sign-in method',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          'Enable Email link (passwordless) in Firebase Console',
        );
      case 'invalid-action-code':
        return const AuthFailure(
          'This sign-in link is invalid or expired. Request a new one.',
        );
      case 'missing-email':
        return AuthFailure(
          error.message ??
              'Open the link on the same device you requested it from.',
        );
      default:
        return AuthFailure(
          error.message ?? 'Authentication failed (${error.code})',
        );
    }
  }
  if (error is GoogleSignInException) {
    if (error.code == GoogleSignInExceptionCode.canceled) {
      return const CancelledFailure();
    }
    return AuthFailure(error.description ?? 'Google Sign-In failed');
  }
  return const UnexpectedFailure();
}
