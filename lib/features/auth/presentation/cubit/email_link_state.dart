part of 'email_link_cubit.dart';

sealed class EmailLinkState extends Equatable {
  const EmailLinkState();

  @override
  List<Object?> get props => [];
}

final class EmailLinkInitial extends EmailLinkState {
  const EmailLinkInitial();
}

final class EmailLinkLoading extends EmailLinkState {
  const EmailLinkLoading();
}

final class EmailLinkSent extends EmailLinkState {
  const EmailLinkSent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class EmailLinkCompleted extends EmailLinkState {
  const EmailLinkCompleted();
}

final class EmailLinkFailure extends EmailLinkState {
  const EmailLinkFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
