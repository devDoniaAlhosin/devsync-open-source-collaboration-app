import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/sign_in_with_github.dart';
import '../../domain/usecases/sign_in_with_google.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({
    required RegisterWithEmail registerWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignInWithGitHub signInWithGitHub,
  }) : _registerWithEmail = registerWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _signInWithGitHub = signInWithGitHub,
       super(const RegisterInitial());

  final RegisterWithEmail _registerWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithGitHub _signInWithGitHub;

  Completer<bool>? _gitHubDeviceCompleter;

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _run(
      () => _registerWithEmail(
        RegisterWithEmailParams(
          email: email,
          password: password,
          displayName: displayName,
        ),
      ),
      afterSuccess: RegisterNeedsVerification(email),
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
              RegisterGitHubDeviceCode(
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

  Future<void> _run(
    Future<Result<void>> Function() action, {
    RegisterState afterSuccess = const RegisterSuccess(),
  }) async {
    if (state is RegisterLoading || state is RegisterGitHubDeviceCode) return;
    emit(const RegisterLoading());
    final result = await action();
    switch (result) {
      case Success():
        _finishGitHubDevicePrompt(proceed: true);
        emit(afterSuccess);
      case FailureResult(:final failure):
        _finishGitHubDevicePrompt(proceed: false);
        if (failure is CancelledFailure) {
          emit(const RegisterInitial());
          return;
        }
        emit(RegisterFailure(failure.message));
    }
  }

  @override
  Future<void> close() {
    _finishGitHubDevicePrompt(proceed: false);
    return super.close();
  }
}
