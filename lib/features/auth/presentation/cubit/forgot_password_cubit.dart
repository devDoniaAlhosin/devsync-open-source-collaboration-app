import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/usecases/reset_password_with_otp.dart';
import '../../domain/usecases/send_password_reset_email.dart';
import '../../domain/usecases/verify_otp.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({
    required this._sendPasswordResetEmail,
    required this._verifyOtp,
    required this._resetPasswordWithOtp,
  }) : super(const ForgotPasswordInitial());

  final SendPasswordResetEmail _sendPasswordResetEmail;
  final VerifyOtp _verifyOtp;
  final ResetPasswordWithOtp _resetPasswordWithOtp;

  Future<void> sendReset(String email) async {
    if (state is ForgotPasswordLoading) return;
    emit(const ForgotPasswordLoading());
    final result = await _sendPasswordResetEmail(email);
    switch (result) {
      case Success():
        emit(ForgotPasswordSent(email));
      case FailureResult(:final failure):
        emit(ForgotPasswordFailure(failure.message));
    }
  }

  Future<void> verifyCode({
    required String email,
    required String code,
  }) async {
    if (state is ForgotPasswordLoading) return;
    emit(const ForgotPasswordLoading());
    final result = await _verifyOtp(
      VerifyOtpParams(email: email, code: code, purpose: 'reset'),
    );
    switch (result) {
      case Success():
        emit(ForgotPasswordCodeVerified(email: email, code: code));
      case FailureResult(:final failure):
        emit(ForgotPasswordFailure(failure.message));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (state is ForgotPasswordLoading) return;
    emit(const ForgotPasswordLoading());
    final result = await _resetPasswordWithOtp(
      ResetPasswordWithOtpParams(
        email: email,
        code: code,
        newPassword: newPassword,
      ),
    );
    switch (result) {
      case Success():
        emit(const ForgotPasswordResetDone());
      case FailureResult(:final failure):
        emit(ForgotPasswordFailure(failure.message));
    }
  }
}
