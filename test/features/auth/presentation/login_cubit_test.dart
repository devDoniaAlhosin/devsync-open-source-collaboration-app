import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/failures/auth_failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/usecases/sign_in_with_github.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/presentation/cubit/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late LoginCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = LoginCubit(
      signInWithEmail: SignInWithEmail(repository),
      signInWithGoogle: SignInWithGoogle(repository),
      signInWithGitHub: SignInWithGitHub(repository),
    );
  });

  tearDown(() => cubit.close());

  test('starts idle', () {
    expect(cubit.state, const LoginInitial());
  });

  test('emits success after email sign-in', () async {
    await cubit.signIn(email: 'a@b.com', password: 'secret');
    expect(cubit.state, const LoginSuccess());
  });

  test('emits failure when the repository fails', () async {
    repository.signInResult = const FailureResult(
      AuthFailure('Invalid email or password'),
    );

    await cubit.signIn(email: 'a@b.com', password: 'nope');

    expect(cubit.state, const LoginFailure('Invalid email or password'));
  });

  test('routes unverified email to verification', () async {
    repository.signInResult = const FailureResult(
      EmailNotVerifiedFailure(email: 'a@b.com'),
    );

    await cubit.signIn(email: 'a@b.com', password: 'secret');

    expect(cubit.state, const LoginNeedsVerification('a@b.com'));
  });

  test('cancelled social sign-in returns to idle', () async {
    repository.signInResult = const FailureResult(CancelledFailure());

    await cubit.signInWithGoogle();

    expect(cubit.state, const LoginInitial());
  });
}
