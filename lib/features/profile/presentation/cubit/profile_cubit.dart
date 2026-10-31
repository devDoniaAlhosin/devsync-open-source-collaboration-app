import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this._getProfile,
    required this._updateProfile,
  }) : super(const ProfileInitial());

  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;

  Future<void> load() async {
    emit(const ProfileLoading());
    final result = await _getProfile(const NoParams());
    switch (result) {
      case Success(:final data):
        emit(ProfileLoaded(data));
      case FailureResult(:final failure):
        emit(ProfileFailure(failure.message));
    }
  }

  Future<void> save({required String bio, required List<String> skills}) async {
    final current = state;
    if (current is ProfileLoaded) {
      emit(ProfileSaving(current.profile));
    } else {
      emit(const ProfileLoading());
    }

    final result = await _updateProfile(
      UpdateProfileParams(bio: bio, skills: skills),
    );
    switch (result) {
      case Success(:final data):
        emit(ProfileLoaded(data));
      case FailureResult(:final failure):
        emit(ProfileFailure(failure.message));
    }
  }
}
