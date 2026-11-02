part of 'verify_code_cubit.dart';

sealed class VerifyCodeState extends Equatable {
  const VerifyCodeState();

  @override
  List<Object?> get props => [];
}

final class VerifyCodeInitial extends VerifyCodeState {
  const VerifyCodeInitial();
}

final class VerifyCodeLoading extends VerifyCodeState {
  const VerifyCodeLoading();
}

final class VerifyCodeSent extends VerifyCodeState {
  const VerifyCodeSent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class VerifyCodeSuccess extends VerifyCodeState {
  const VerifyCodeSuccess();
}

final class VerifyCodeFailure extends VerifyCodeState {
  const VerifyCodeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
