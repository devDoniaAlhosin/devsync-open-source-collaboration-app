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
    required this._registerWithEmail,
    required this._signInWithGoogle,
    required this._signInWithGitHub,
  }) : super(const RegisterInitial());

  final RegisterWithEmail _registerWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithGitHub _signInWithGitHub;

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

  Future<void> signInWithGitHub() =>
      _run(() => _signInWithGitHub(const NoParams()));

  Future<void> _run(
    Future<Result<void>> Function() action, {
    RegisterState afterSuccess = const RegisterSuccess(),
  }) async {
    if (state is RegisterLoading) return;
    emit(const RegisterLoading());
    final result = await action();
    switch (result) {
      case Success():
        emit(afterSuccess);
      case FailureResult(:final failure):
        if (failure is CancelledFailure) {
          emit(const RegisterInitial());
          return;
        }
        emit(RegisterFailure(failure.message));
    }
  }
}
