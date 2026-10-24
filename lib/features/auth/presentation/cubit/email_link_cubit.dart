import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/complete_email_link_sign_in.dart';
import '../../domain/usecases/send_sign_in_link.dart';

part 'email_link_state.dart';

class EmailLinkCubit extends Cubit<EmailLinkState> {
  EmailLinkCubit({
    required this._sendSignInLink,
    required this._completeEmailLinkSignIn,
    required this._authRepository,
  }) : super(const EmailLinkInitial());

  final SendSignInLink _sendSignInLink;
  final CompleteEmailLinkSignIn _completeEmailLinkSignIn;
  final AuthRepository _authRepository;

  bool isSignInWithEmailLink(String link) =>
      _authRepository.isSignInWithEmailLink(link);

  Future<String?> pendingEmailLinkAddress() {
    return _authRepository.pendingEmailLinkAddress();
  }

  Future<void> sendLink(String email) async {
    if (state is EmailLinkLoading) return;
    emit(const EmailLinkLoading());
    final result = await _sendSignInLink(email);
    switch (result) {
      case Success():
        emit(EmailLinkSent(email));
      case FailureResult(:final failure):
        emit(EmailLinkFailure(failure.message));
    }
  }

  Future<void> completeLink(String link) async {
    if (state is EmailLinkLoading) return;
    emit(const EmailLinkLoading());
    final result = await _completeEmailLinkSignIn(link);
    switch (result) {
      case Success():
        emit(const EmailLinkCompleted());
      case FailureResult(:final failure):
        emit(EmailLinkFailure(failure.message));
    }
  }
}
