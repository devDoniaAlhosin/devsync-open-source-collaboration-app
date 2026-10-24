import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/data/mappers/auth_failure_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps requires-recent-login to the delete message', () {
    final failure = mapAuthError(
      FirebaseAuthException(code: 'requires-recent-login'),
    );

    expect(failure, isA<AuthFailure>());
    expect(failure.message, 'Sign in again, then delete your account');
  });

  test('maps invalid-credential to invalid email or password', () {
    final failure = mapAuthError(
      FirebaseAuthException(code: 'invalid-credential'),
    );

    expect(failure, isA<AuthFailure>());
    expect(failure.message, 'Invalid email or password');
  });

  test('maps cancelled social sign-in', () {
    final failure = mapAuthError(const AuthCancelledException());

    expect(failure, isA<CancelledFailure>());
  });

  test('maps Google-only account to continue-with-Google message', () {
    final failure = mapAuthError(const GoogleOnlyAccountException());

    expect(failure, isA<AuthFailure>());
    expect(
      failure.message,
      'This account uses Google. Continue with Google instead.',
    );
  });
}
