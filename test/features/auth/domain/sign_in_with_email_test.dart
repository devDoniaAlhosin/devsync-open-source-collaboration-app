import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  test('returns success from the repository', () async {
    final repository = FakeAuthRepository();
    final useCase = SignInWithEmail(repository);

    final result = await useCase(
      const SignInWithEmailParams(email: 'a@b.com', password: 'secret'),
    );

    expect(result, isA<Success<void>>());
  });

  test('returns failure from the repository', () async {
    final repository = FakeAuthRepository(
      signInResult: const FailureResult(
        AuthFailure('Invalid email or password'),
      ),
    );
    final useCase = SignInWithEmail(repository);

    final result = await useCase(
      const SignInWithEmailParams(email: 'a@b.com', password: 'nope'),
    );

    expect(result, isA<FailureResult<void>>());
    expect(
      (result as FailureResult<void>).failure.message,
      'Invalid email or password',
    );
  });
}
