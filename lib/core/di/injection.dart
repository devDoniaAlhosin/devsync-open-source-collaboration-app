import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/user_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/complete_email_link_sign_in.dart';
import '../../features/auth/domain/usecases/register_with_email.dart';
import '../../features/auth/domain/usecases/reload_email_verification.dart';
import '../../features/auth/domain/usecases/send_email_verification.dart';
import '../../features/auth/domain/usecases/send_sign_in_link.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_github.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/email_link_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/register_cubit.dart';
import '../../features/auth/presentation/cubit/verify_email_cubit.dart';

final GetIt getIt = GetIt.instance;

/// Composition root. Safe to call more than once (tests / hot restart).
Future<void> configureDependencies() async {
  if (getIt.isRegistered<AuthRepository>()) return;

  getIt
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance)
    ..registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSource(firestore: getIt()),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        auth: getIt(),
        userRemoteDataSource: getIt(),
        googleSignIn: getIt(),
      ),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()))
    ..registerLazySingleton(() => WatchAuthState(getIt()))
    ..registerLazySingleton(() => SignInWithEmail(getIt()))
    ..registerLazySingleton(() => RegisterWithEmail(getIt()))
    ..registerLazySingleton(() => SignInWithGoogle(getIt()))
    ..registerLazySingleton(() => SignInWithGitHub(getIt()))
    ..registerLazySingleton(() => SignOut(getIt()))
    ..registerLazySingleton(() => SendSignInLink(getIt()))
    ..registerLazySingleton(() => CompleteEmailLinkSignIn(getIt()))
    ..registerLazySingleton(() => SendEmailVerification(getIt()))
    ..registerLazySingleton(() => ReloadEmailVerification(getIt()))
    ..registerLazySingleton(
      () => AuthCubit(watchAuthState: getIt(), signOut: getIt()),
    )
    ..registerFactory(
      () => LoginCubit(
        signInWithEmail: getIt(),
        signInWithGoogle: getIt(),
        signInWithGitHub: getIt(),
      ),
    )
    ..registerFactory(
      () => RegisterCubit(
        registerWithEmail: getIt(),
        signInWithGoogle: getIt(),
        signInWithGitHub: getIt(),
      ),
    )
    ..registerFactory(
      () => EmailLinkCubit(
        sendSignInLink: getIt(),
        completeEmailLinkSignIn: getIt(),
        authRepository: getIt(),
      ),
    )
    ..registerFactory(
      () => VerifyEmailCubit(
        sendEmailVerification: getIt(),
        reloadEmailVerification: getIt(),
        signOut: getIt(),
        authRepository: getIt(),
      ),
    );
}

/// Test composition root — register a fake [AuthRepository] first, then call this.
void registerAuthUseCasesAndCubits() {
  if (!getIt.isRegistered<WatchAuthState>()) {
    getIt
      ..registerLazySingleton(() => WatchAuthState(getIt()))
      ..registerLazySingleton(() => SignInWithEmail(getIt()))
      ..registerLazySingleton(() => RegisterWithEmail(getIt()))
      ..registerLazySingleton(() => SignInWithGoogle(getIt()))
      ..registerLazySingleton(() => SignInWithGitHub(getIt()))
      ..registerLazySingleton(() => SignOut(getIt()))
      ..registerLazySingleton(() => SendSignInLink(getIt()))
      ..registerLazySingleton(() => CompleteEmailLinkSignIn(getIt()))
      ..registerLazySingleton(() => SendEmailVerification(getIt()))
      ..registerLazySingleton(() => ReloadEmailVerification(getIt()));
  }

  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerLazySingleton(
      () => AuthCubit(watchAuthState: getIt(), signOut: getIt()),
    );
  }
  if (!getIt.isRegistered<LoginCubit>()) {
    getIt
      ..registerFactory(
        () => LoginCubit(
          signInWithEmail: getIt(),
          signInWithGoogle: getIt(),
          signInWithGitHub: getIt(),
        ),
      )
      ..registerFactory(
        () => RegisterCubit(
          registerWithEmail: getIt(),
          signInWithGoogle: getIt(),
          signInWithGitHub: getIt(),
        ),
      )
      ..registerFactory(
        () => EmailLinkCubit(
          sendSignInLink: getIt(),
          completeEmailLinkSignIn: getIt(),
          authRepository: getIt(),
        ),
      )
      ..registerFactory(
        () => VerifyEmailCubit(
          sendEmailVerification: getIt(),
          reloadEmailVerification: getIt(),
          signOut: getIt(),
          authRepository: getIt(),
        ),
      );
  }
}
