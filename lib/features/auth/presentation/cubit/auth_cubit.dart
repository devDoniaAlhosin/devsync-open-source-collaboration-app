import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/app_user.dart';
import '../../../../core/result/result.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/watch_auth_state.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this._watchAuthState,
    required this._signOut,
    required this._deleteAccount,
  }) : super(const AuthInitial()) {
    _subscription = _watchAuthState(const NoParams()).listen(_onUser);
  }

  final WatchAuthState _watchAuthState;
  final SignOut _signOut;
  final DeleteAccount _deleteAccount;
  StreamSubscription<AppUser?>? _subscription;

  void refresh() => _onUser(_watchAuthState.currentUser());

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
    emit(const AuthSignedOut());
  }

  Future<Result<void>> deleteAccount() async {
    final result = await _deleteAccount(const NoParams());
    await _signOut(const NoParams());
    emit(const AuthSignedOut());
    return result;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
