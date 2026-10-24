import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/usecases/send_password_reset_email.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required this._sendPasswordResetEmail})
    : super(const ForgotPasswordInitial());

  final SendPasswordResetEmail _sendPasswordResetEmail;

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
}
