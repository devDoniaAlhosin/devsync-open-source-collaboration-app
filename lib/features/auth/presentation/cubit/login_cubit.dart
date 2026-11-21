import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_github.dart';
import '../../domain/usecases/sign_in_with_google.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required SignInWithEmail signInWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignInWithGitHub signInWithGitHub,
  }) : _signInWithEmail = signInWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _signInWithGitHub = signInWithGitHub,
       super(const LoginInitial());

  final SignInWithEmail _signInWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithGitHub _signInWithGitHub;

  Completer<bool>? _gitHubDeviceCompleter;

  Future<void> signIn({required String email, required String password}) {
    return _run(
      () => _signInWithEmail(
        SignInWithEmailParams(email: email, password: password),
      ),
    );
  }

  Future<void> signInWithGoogle() =>
      _run(() => _signInWithGoogle(const NoParams()));

  Future<void> signInWithGitHub() {
    return _run(
      () => _signInWithGitHub(
        SignInWithGitHubParams(
          onDeviceCode: (userCode, verificationUri) async {
            final completer = Completer<bool>();
            _gitHubDeviceCompleter = completer;
            emit(
              LoginGitHubDeviceCode(
                userCode: userCode,
                verificationUri: verificationUri.toString(),
              ),
            );
            return completer.future;
          },
        ),
      ),
    );
  }

  void cancelGitHubDeviceCode() {
    final completer = _gitHubDeviceCompleter;
    if (completer == null || completer.isCompleted) return;
    completer.complete(false);
  }

  void _finishGitHubDevicePrompt({required bool proceed}) {
    final completer = _gitHubDeviceCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(proceed);
    }
    _gitHubDeviceCompleter = null;
  }

  Future<void> _run(Future<Result<void>> Function() action) async {
    if (state is LoginLoading || state is LoginGitHubDeviceCode) return;
    emit(const LoginLoading());
    final result = await action();
    switch (result) {
      case Success():
        _finishGitHubDevicePrompt(proceed: true);
        emit(const LoginSuccess());
      case FailureResult(:final failure):
        _finishGitHubDevicePrompt(proceed: false);
        if (failure is CancelledFailure) {
          emit(const LoginInitial());
          return;
        }
        if (failure is EmailNotVerifiedFailure) {
          emit(LoginNeedsVerification(failure.email));
          return;
        }
        emit(LoginFailure(failure.message));
    }
  }

  @override
  Future<void> close() {
    _finishGitHubDevicePrompt(proceed: false);
    return super.close();
  }
}
