import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../matching/domain/entities/github_scan_result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/save_github_scan.dart';
import '../../domain/usecases/scan_github_profile.dart';
import '../../domain/usecases/update_profile.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required SaveGithubScan saveGithubScan,
    required ScanGithubProfile scanGithubProfile,
    Future<String?> Function()? resolveGithubLoginHint,
  }) : _getProfile = getProfile,
       _updateProfile = updateProfile,
       _saveGithubScan = saveGithubScan,
       _scanGithubProfile = scanGithubProfile,
       _resolveGithubLoginHint = resolveGithubLoginHint,
       super(const ProfileInitial());

  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final SaveGithubScan _saveGithubScan;
  final ScanGithubProfile _scanGithubProfile;
  final Future<String?> Function()? _resolveGithubLoginHint;

  /// Prefill username from OAuth store / user doc (wired in DI).
  Future<String> loadGithubLoginHint() async {
    try {
      return (await _resolveGithubLoginHint?.call())?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

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

  Future<void> scanGithub(String username) async {
    if (state is ProfileGithubScanning || state is ProfileLoading) return;
    emit(const ProfileGithubScanning());
    final result = await _scanGithubProfile(ScanGithubProfileParams(username));
    switch (result) {
      case Success(:final data):
        emit(ProfileGithubScanReady(data));
      case FailureResult(:final failure):
        emit(ProfileGithubScanFailure(failure.message));
    }
  }

  void clearGithubScan() {
    if (state is ProfileGithubScanReady || state is ProfileGithubScanFailure) {
      emit(const ProfileInitial());
    }
  }

  Future<void> saveGithubScan({
    required String githubUsername,
    required int repos,
    required int commits,
    required List<LanguageShare> languages,
    String? bioSuggestion,
    List<List<int>> activity = const [],
  }) async {
    if (state is ProfileLoading) return; // ignore double taps
    emit(const ProfileLoading());
    final result = await _saveGithubScan(
      SaveGithubScanParams(
        githubUsername: githubUsername,
        repos: repos,
        commits: commits,
        languages: languages,
        bioSuggestion: bioSuggestion,
        activity: activity,
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
