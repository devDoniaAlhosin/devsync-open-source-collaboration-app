import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/reload_email_verification.dart';
import '../../domain/usecases/send_email_verification.dart';
import '../../domain/usecases/sign_out.dart';

part 'verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  VerifyEmailCubit({
    required this._sendEmailVerification,
    required this._reloadEmailVerification,
    required this._signOut,
    required this._authRepository,
  }) : super(const VerifyEmailInitial());

  final SendEmailVerification _sendEmailVerification;
  final ReloadEmailVerification _reloadEmailVerification;
  final SignOut _signOut;
  final AuthRepository _authRepository;

  String? get currentEmail => _authRepository.currentUser?.email;

  Future<void> resend() async {
    if (state is VerifyEmailResending || state is VerifyEmailChecking) return;
    emit(const VerifyEmailResending());
    final result = await _sendEmailVerification(const NoParams());
    switch (result) {
      case Success():
        emit(const VerifyEmailResent());
      case FailureResult(:final failure):
        emit(VerifyEmailFailure(failure.message));
    }
  }

  Future<void> checkVerified({bool silent = false}) async {
    if (state is VerifyEmailChecking || state is VerifyEmailResending) return;
    emit(const VerifyEmailChecking());
    final result = await _reloadEmailVerification(const NoParams());
    switch (result) {
      case Success(:final data):
        if (data) {
          emit(const VerifyEmailVerified());
        } else if (silent) {
          emit(const VerifyEmailInitial());
        } else {
          emit(const VerifyEmailNotYet());
        }
      case FailureResult(:final failure):
        emit(VerifyEmailFailure(failure.message));
    }
  }

  Future<void> useAnotherAccount() async {
    await _signOut(const NoParams());
    emit(const VerifyEmailSignedOut());
  }
}
