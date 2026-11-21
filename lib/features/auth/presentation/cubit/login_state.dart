part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess();
}

final class LoginNeedsVerification extends LoginState {
  const LoginNeedsVerification(this.email);

  final String? email;

  @override
  List<Object?> get props => [email];
}

final class LoginGitHubDeviceCode extends LoginState {
  const LoginGitHubDeviceCode({
    required this.userCode,
    required this.verificationUri,
  });

  final String userCode;
  final String verificationUri;

  @override
  List<Object?> get props => [userCode, verificationUri];
}

final class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
