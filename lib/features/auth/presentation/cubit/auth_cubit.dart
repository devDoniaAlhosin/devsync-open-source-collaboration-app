import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/watch_auth_state.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this._watchAuthState,
    required this._signOut,
  }) : super(const AuthInitial()) {
    _subscription = _watchAuthState(const NoParams()).listen(_onUser);
  }

  final WatchAuthState _watchAuthState;
  final SignOut _signOut;
  StreamSubscription<AppUser?>? _subscription;

  void _onUser(AppUser? user) {
    if (user == null) {
      emit(const AuthSignedOut());
      return;
    }
    if (user.needsEmailVerification) {
      emit(AuthNeedsVerification(user));
      return;
    }
    emit(AuthAuthenticated(user));
  }

  Future<void> signOut() async {
    await _signOut(const NoParams());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
