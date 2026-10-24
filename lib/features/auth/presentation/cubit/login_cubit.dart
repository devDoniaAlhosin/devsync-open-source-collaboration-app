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
    required this._signInWithEmail,
    required this._signInWithGoogle,
    required this._signInWithGitHub,
  }) : super(const LoginInitial());

  final SignInWithEmail _signInWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithGitHub _signInWithGitHub;

  Future<void> signIn({required String email, required String password}) {
    return _run(
      () => _signInWithEmail(
        SignInWithEmailParams(email: email, password: password),
      ),
    );
  }

  Future<void> signInWithGoogle() =>
      _run(() => _signInWithGoogle(const NoParams()));

  Future<void> signInWithGitHub() =>
      _run(() => _signInWithGitHub(const NoParams()));

  Future<void> _run(Future<Result<void>> Function() action) async {
    if (state is LoginLoading) return;
    emit(const LoginLoading());
    final result = await action();
    switch (result) {
      case Success():
        emit(const LoginSuccess());
      case FailureResult(:final failure):
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
}
