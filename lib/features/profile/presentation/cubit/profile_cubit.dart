import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/save_github_scan.dart';
import '../../domain/usecases/update_profile.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required SaveGithubScan saveGithubScan,
  }) : _getProfile = getProfile,
       _updateProfile = updateProfile,
       _saveGithubScan = saveGithubScan,
       super(const ProfileInitial());

  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final SaveGithubScan _saveGithubScan;

  Profile? get _current => switch (state) {
    ProfileLoaded(:final profile) ||
    ProfileSaving(:final profile) ||
    ProfileSaveFailure(:final profile) => profile,
    _ => null,
  };

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
    final current = _current;
    if (current == null) return;

    emit(ProfileSaving(current));
    final result = await _updateProfile(
      UpdateProfileParams(bio: bio, skills: skills),
    );
    switch (result) {
      case Success(:final data):
        emit(ProfileLoaded(data));
      case FailureResult(:final failure):
        emit(ProfileSaveFailure(current, failure.message));
    }
  }

  Future<void> saveGithubScan({
    required String githubUsername,
    required int repos,
    required int commits,
    required List<LanguageShare> languages,
  }) async {
    if (state is ProfileLoading) return; // ignore double taps
    emit(const ProfileLoading());
    final result = await _saveGithubScan(
      SaveGithubScanParams(
        githubUsername: githubUsername,
        repos: repos,
        commits: commits,
        languages: languages,
      ),
    );
    switch (result) {
      case Success(:final data):
        emit(ProfileLoaded(data));
      case FailureResult(:final failure):
        emit(ProfileFailure(failure.message));
    }
  }
}
