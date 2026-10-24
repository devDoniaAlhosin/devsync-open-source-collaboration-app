import 'dart:async';

import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/entities/app_user.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/usecases/delete_account.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/usecases/sign_out.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

const _verified = AppUser(uid: 'u1', email: 'a@b.com');
const _unverified = AppUser(
  uid: 'u2',
  email: 'a@b.com',
  needsEmailVerification: true,
);

void main() {
  late StreamController<AppUser?> events;
  late FakeAuthRepository repository;
  late AuthCubit cubit;

  setUp(() {
    events = StreamController<AppUser?>.broadcast();
    repository = FakeAuthRepository(authState: events.stream);
    cubit = AuthCubit(
      watchAuthState: WatchAuthState(repository),
      signOut: SignOut(repository),
      deleteAccount: DeleteAccount(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
    await events.close();
  });

  Future<void> _emit(AppUser? user) async {
    events.add(user);
    await Future<void>.delayed(Duration.zero);
  }

  test('null user emits signed out', () async {
    await _emit(null);
    expect(cubit.state, const AuthSignedOut());
  });

  test('unverified user emits needs verification', () async {
    await _emit(_unverified);
    expect(cubit.state, const AuthNeedsVerification(_unverified));
  });

  test('verified user emits authenticated', () async {
    await _emit(_verified);
    expect(cubit.state, const AuthAuthenticated(_verified));
  });

  test('deleteAccount success still signs out', () async {
    final result = await cubit.deleteAccount();

    expect(result, isA<Success<void>>());
    expect(repository.deleteCalls, 1);
    expect(repository.signOutCalls, greaterThanOrEqualTo(1));
    expect(cubit.state, const AuthSignedOut());
  });

  test('deleteAccount failure still signs out', () async {
    repository.deleteResult = const FailureResult(
      AuthFailure('Sign in again, then delete your account'),
    );

    final result = await cubit.deleteAccount();

    expect(result, isA<FailureResult<void>>());
    expect(repository.deleteCalls, 1);
    expect(repository.signOutCalls, greaterThanOrEqualTo(1));
    expect(cubit.state, const AuthSignedOut());
  });
}
