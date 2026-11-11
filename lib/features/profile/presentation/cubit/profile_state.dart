part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);

  final Profile profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileSaving extends ProfileState {
  const ProfileSaving(this.profile);

  final Profile profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileSaveFailure extends ProfileState {
  const ProfileSaveFailure(this.profile, this.message);

  final Profile profile;
  final String message;

  @override
  List<Object?> get props => [profile, message];
}
