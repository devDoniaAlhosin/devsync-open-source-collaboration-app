part of 'register_cubit.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

final class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

final class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

final class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

final class RegisterNeedsVerification extends RegisterState {
  const RegisterNeedsVerification(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class RegisterFailure extends RegisterState {
  const RegisterFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
