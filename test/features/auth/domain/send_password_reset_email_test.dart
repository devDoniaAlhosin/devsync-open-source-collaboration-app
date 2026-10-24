import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  test('returns success from the repository', () async {
    final repository = FakeAuthRepository();
    final useCase = SendPasswordResetEmail(repository);

    final result = await useCase('nour@mail.com');

    expect(result, isA<Success<void>>());
    expect(repository.resetCalls, 1);
  });

  test('returns failure from the repository', () async {
    final repository = FakeAuthRepository(
      resetResult: const FailureResult(NetworkFailure()),
    );
    final useCase = SendPasswordResetEmail(repository);

    final result = await useCase('nour@mail.com');

    expect(result, isA<FailureResult<void>>());
    expect(repository.resetCalls, 1);
  });
}
