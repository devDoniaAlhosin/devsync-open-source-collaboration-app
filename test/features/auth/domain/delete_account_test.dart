import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/core/usecase/usecase.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/usecases/delete_account.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  test('returns success from the repository', () async {
    final repository = FakeAuthRepository();
    final useCase = DeleteAccount(repository);

    final result = await useCase(const NoParams());

    expect(result, isA<Success<void>>());
    expect(repository.deleteCalls, 1);
  });

  test('returns failure from the repository', () async {
    final repository = FakeAuthRepository(
      deleteResult: const FailureResult(
        AuthFailure('Sign in again, then delete your account'),
      ),
    );
    final useCase = DeleteAccount(repository);

    final result = await useCase(const NoParams());

    expect(result, isA<FailureResult<void>>());
    expect(
      (result as FailureResult<void>).failure.message,
      'Sign in again, then delete your account',
    );
    expect(repository.deleteCalls, 1);
  });
}
