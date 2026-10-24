import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late ForgotPasswordCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = ForgotPasswordCubit(
      sendPasswordResetEmail: SendPasswordResetEmail(repository),
    );
  });

  tearDown(() => cubit.close());

  test('starts idle', () {
    expect(cubit.state, const ForgotPasswordInitial());
  });

  test('emits sent after a reset email succeeds', () async {
    await cubit.sendReset('nour@mail.com');
    expect(cubit.state, const ForgotPasswordSent('nour@mail.com'));
    expect(repository.resetCalls, 1);
  });

  test('emits failure when the repository fails', () async {
    repository.resetResult = const FailureResult(NetworkFailure());

    await cubit.sendReset('nour@mail.com');

    expect(cubit.state, ForgotPasswordFailure(const NetworkFailure().message));
    expect(repository.resetCalls, 1);
  });
}
