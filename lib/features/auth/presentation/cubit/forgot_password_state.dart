part of 'forgot_password_cubit.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

final class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

final class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

final class ForgotPasswordSent extends ForgotPasswordState {
  const ForgotPasswordSent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class ForgotPasswordCodeVerified extends ForgotPasswordState {
  const ForgotPasswordCodeVerified({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;

  @override
  List<Object?> get props => [email, code];
}

final class ForgotPasswordResetDone extends ForgotPasswordState {
  const ForgotPasswordResetDone();
}

final class ForgotPasswordFailure extends ForgotPasswordState {
  const ForgotPasswordFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
