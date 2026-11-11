import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/usecases/confirm_email_with_otp.dart';
import '../../domain/usecases/send_email_otp.dart';
import '../../domain/usecases/sign_in_with_email_otp.dart';

part 'verify_code_state.dart';

class VerifyCodeCubit extends Cubit<VerifyCodeState> {
  VerifyCodeCubit({
    required SendEmailOtp sendEmailOtp,
    required ConfirmEmailWithOtp confirmEmailWithOtp,
    required SignInWithEmailOtp signInWithEmailOtp,
  }) : _sendEmailOtp = sendEmailOtp,
       _confirmEmailWithOtp = confirmEmailWithOtp,
       _signInWithEmailOtp = signInWithEmailOtp,
       super(const VerifyCodeInitial());

  final SendEmailOtp _sendEmailOtp;
  final ConfirmEmailWithOtp _confirmEmailWithOtp;
  final SignInWithEmailOtp _signInWithEmailOtp;

  Future<void> sendCode(String email, {String purpose = 'verify'}) async {
    if (state is VerifyCodeLoading) return;
    emit(const VerifyCodeLoading());
    final result = await _sendEmailOtp(
      SendEmailOtpParams(email: email, purpose: purpose),
    );
    switch (result) {
      case Success():
        emit(VerifyCodeSent(email));
      case FailureResult(:final failure):
        emit(VerifyCodeFailure(failure.message));
    }
  }

  Future<void> confirm({
    required String email,
    required String code,
    String purpose = 'verify',
  }) async {
    if (state is VerifyCodeLoading) return;
    emit(const VerifyCodeLoading());

    final Result<void> result;
    if (purpose == 'signin') {
      result = await _signInWithEmailOtp(
        SignInWithEmailOtpParams(email: email, code: code),
      );
    } else {
      result = await _confirmEmailWithOtp(
        ConfirmEmailWithOtpParams(email: email, code: code),
      );
    }

    switch (result) {
      case Success():
        emit(const VerifyCodeSuccess());
      case FailureResult(:final failure):
        emit(VerifyCodeFailure(failure.message));
    }
  }
}
