part of 'verify_email_cubit.dart';

sealed class VerifyEmailState extends Equatable {
  const VerifyEmailState();

  @override
  List<Object?> get props => [];
}

final class VerifyEmailInitial extends VerifyEmailState {
  const VerifyEmailInitial();
}

final class VerifyEmailResending extends VerifyEmailState {
  const VerifyEmailResending();
}

final class VerifyEmailResent extends VerifyEmailState {
  const VerifyEmailResent();
}

final class VerifyEmailChecking extends VerifyEmailState {
  const VerifyEmailChecking();
}

final class VerifyEmailVerified extends VerifyEmailState {
  const VerifyEmailVerified();
}

final class VerifyEmailNotYet extends VerifyEmailState {
  const VerifyEmailNotYet();
}

final class VerifyEmailSignedOut extends VerifyEmailState {
  const VerifyEmailSignedOut();
}

final class VerifyEmailFailure extends VerifyEmailState {
  const VerifyEmailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
