part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

final class AuthNeedsVerification extends AuthState {
  const AuthNeedsVerification(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user.uid, user.email];
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user.uid];
}
