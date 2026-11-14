import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/user_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/delete_account.dart';
import '../../features/auth/domain/usecases/register_with_email.dart';
import '../../features/auth/domain/usecases/confirm_email_with_otp.dart';
import '../../features/auth/domain/usecases/reset_password_with_otp.dart';
import '../../features/auth/domain/usecases/send_email_otp.dart';
import '../../features/auth/domain/usecases/send_password_reset_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_email_otp.dart';
import '../../features/auth/domain/usecases/verify_otp.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_github.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/verify_code_cubit.dart';
import '../../features/auth/presentation/cubit/register_cubit.dart';
import '../../features/matching/domain/repositories/matching_repository.dart';
import '../../features/matching/domain/usecases/generate_matches_usecase.dart';
import '../../features/matching/domain/usecases/get_matching_analytics_usecase.dart';
import '../../features/matching/domain/usecases/get_ranked_matches_usecase.dart';
import '../../features/matching/matching_dependencies.dart';
import '../../features/matching/presentation/cubit/matching_cubit.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/projects/projects_dependencies.dart';
import '../../features/requests/data/datasources/requests_remote_data_source.dart';
import '../../features/requests/data/repositories/requests_repository_impl.dart';
import '../../features/requests/domain/repositories/requests_repository.dart';
import '../../features/requests/domain/usecases/get_requests.dart';
import '../../features/requests/domain/usecases/update_request_status.dart';
import '../../features/requests/presentation/cubit/requests_cubit.dart';
import '../../features/requests/domain/usecases/create_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/profile/domain/usecases/save_github_scan.dart';

final GetIt getIt = GetIt.instance;

/// Composition root. Safe to call more than once (tests / hot restart).
Future<void> configureDependencies() async {
  if (getIt.isRegistered<AuthRepository>()) return;

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

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
    ..registerLazySingleton(() => DeleteAccount(getIt()))
    ..registerLazySingleton(() => SendPasswordResetEmail(getIt()))
    ..registerLazySingleton(() => SendEmailOtp(getIt()))
    ..registerLazySingleton(() => VerifyOtp(getIt()))
    ..registerLazySingleton(() => ResetPasswordWithOtp(getIt()))
    ..registerLazySingleton(() => ConfirmEmailWithOtp(getIt()))
    ..registerLazySingleton(() => SignInWithEmailOtp(getIt()))
    ..registerLazySingleton(
      () => AuthCubit(
        watchAuthState: getIt(),
        signOut: getIt(),
        deleteAccount: getIt(),
      ),
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
      () => ForgotPasswordCubit(
        sendPasswordResetEmail: getIt(),
        verifyOtp: getIt(),
        resetPasswordWithOtp: getIt(),
      ),
    )
    ..registerFactory(
      () => VerifyCodeCubit(
        sendEmailOtp: getIt(),
        confirmEmailWithOtp: getIt(),
        signInWithEmailOtp: getIt(),
      ),
    );

  _registerMatching();
  _registerProfile();
  registerProjectsDependencies(getIt);
  _registerRequests();
}

void _registerMatching() {
  if (getIt.isRegistered<MatchingRepository>()) return;

  getIt
    ..registerLazySingleton<MatchingRepository>(createMatchingRepository)
    ..registerLazySingleton(() => GetRankedMatchesUseCase(getIt()))
    ..registerLazySingleton(() => GenerateMatchesUseCase(getIt()))
    ..registerLazySingleton(() => GetMatchingAnalyticsUseCase(getIt()))
    ..registerFactory(
      () => MatchingCubit(repository: getIt<MatchingRepository>()),
    );
}

void _registerProfile() {
  if (getIt.isRegistered<ProfileRepository>()) return;

  getIt
    ..registerLazySingleton(
      () => ProfileRemoteDataSource(auth: getIt(), firestore: getIt()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton(() => GetProfile(getIt()))
    ..registerLazySingleton(() => UpdateProfile(getIt()))
    ..registerLazySingleton(() => SaveGithubScan(getIt()))
    ..registerFactory(
      () => ProfileCubit(
        getProfile: getIt(),
        updateProfile: getIt(),
        saveGithubScan: getIt(),
      ),
    );
}

void _registerRequests() {
  if (getIt.isRegistered<RequestsRepository>()) return;

  getIt
    ..registerLazySingleton<RequestsRemoteDataSource>(
      () => RequestsRemoteDataSource(
        firestore: getIt<FirebaseFirestore>(),
        auth: getIt<FirebaseAuth>(),
      ),
    )
    ..registerLazySingleton<RequestsRepository>(
      () => RequestsRepositoryImpl(
        remoteDataSource: getIt<RequestsRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton(() => GetRequests(getIt()))
    ..registerLazySingleton(() => UpdateRequestStatus(getIt()))
    ..registerLazySingleton(() => CreateRequest(getIt()))
    ..registerFactory(
      () => RequestsCubit(
        createRequest: getIt(),
        getRequests: getIt(),
        updateRequestStatus: getIt(),
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
      ..registerLazySingleton(() => DeleteAccount(getIt()))
      ..registerLazySingleton(() => SendPasswordResetEmail(getIt()))
      ..registerLazySingleton(() => SendEmailOtp(getIt()))
      ..registerLazySingleton(() => VerifyOtp(getIt()))
      ..registerLazySingleton(() => ResetPasswordWithOtp(getIt()))
      ..registerLazySingleton(() => ConfirmEmailWithOtp(getIt()))
      ..registerLazySingleton(() => SignInWithEmailOtp(getIt()));
  }

  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerLazySingleton(
      () => AuthCubit(
        watchAuthState: getIt(),
        signOut: getIt(),
        deleteAccount: getIt(),
      ),
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
        () => ForgotPasswordCubit(
          sendPasswordResetEmail: getIt(),
          verifyOtp: getIt(),
          resetPasswordWithOtp: getIt(),
        ),
      )
      ..registerFactory(
        () => VerifyCodeCubit(
          sendEmailOtp: getIt(),
          confirmEmailWithOtp: getIt(),
          signInWithEmailOtp: getIt(),
        ),
      );
  }
}
