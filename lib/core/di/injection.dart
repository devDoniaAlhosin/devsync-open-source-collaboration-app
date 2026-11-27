import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/github_token_store.dart';
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
import '../../features/matching/data/datasources/liked_matches_local_data_source.dart';
import '../../features/matching/data/datasources/matching_feedback_remote_data_source.dart';
import '../../features/matching/data/repositories/firestore_feedback_repository.dart';
import '../../features/matching/data/repositories/firestore_matching_profile_repository.dart';
import '../../features/matching/data/repositories/matching_feedback_repository_impl.dart';
import '../../features/matching/domain/repositories/feedback_repository.dart';
import '../../features/matching/domain/repositories/matching_feedback_repository.dart';
import '../../features/matching/domain/repositories/matching_profile_repository.dart';
import '../../features/matching/domain/repositories/matching_repository.dart';
import '../../features/matching/domain/usecases/get_matching_analytics_usecase.dart';
import '../../features/matching/domain/usecases/get_ranked_matches_usecase.dart';
import '../../features/matching/domain/usecases/get_prompt_quality_metrics.dart';
import '../../features/matching/domain/usecases/get_user_feedback_usecase.dart';
import '../../features/matching/domain/usecases/save_match_feedback.dart';
import '../../features/matching/matching_dependencies.dart';
import '../../features/matching/presentation/cubit/matching_cubit.dart';
import '../../features/profile/data/datasources/github_profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/scan_github_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/projects/domain/usecases/get_projects.dart';
import '../../features/projects/projects_dependencies.dart';
import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/data/datasources/notify_remote_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications.dart';
import '../../features/notifications/domain/usecases/mark_notification_read.dart';
import '../../features/notifications/domain/usecases/watch_unread_notifications.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/requests/data/datasources/requests_remote_data_source.dart';
import '../../features/requests/data/repositories/requests_repository_impl.dart';
import '../../features/requests/domain/repositories/requests_repository.dart';
import '../../features/requests/domain/usecases/get_requests.dart';
import '../../features/requests/domain/usecases/get_unavailable_project_ids.dart';
import '../../features/requests/domain/usecases/update_request_status.dart';
import '../../features/requests/domain/usecases/watch_pending_received_requests.dart';
import '../../features/requests/presentation/cubit/requests_cubit.dart';
import '../../features/requests/domain/usecases/create_request.dart';
import '../../features/shell/presentation/cubit/inbox_badges_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/profile/domain/usecases/save_github_scan.dart';
import '../../features/profile/data/datasources/insights_remote_data_source.dart';
import '../../features/profile/data/repositories/insights_repository_impl.dart';
import '../../features/profile/domain/repositories/insights_repository.dart';
import '../../features/profile/domain/usecases/get_insights.dart';
import '../../features/profile/presentation/cubit/insights_cubit.dart';
import '../notifications/fcm_service.dart';
import '../notifications/notification_preferences.dart';

final GetIt getIt = GetIt.instance;

/// Composition root. Safe to call more than once (tests / hot restart).
Future<void> configureDependencies({
  void Function(String title, String body)? onForegroundMessage,
  void Function()? onNotificationOpened,
}) async {
  if (getIt.isRegistered<AuthRepository>()) {
    _ensureNotificationPreferences();
    _registerFcmService(onForegroundMessage, onNotificationOpened);
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton(
      () => NotificationPreferencesService(
        prefs: getIt(),
        auth: getIt(),
        firestore: getIt(),
      ),
    )
    ..registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance)
    ..registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSource(firestore: getIt()),
    )
    ..registerLazySingleton<GithubTokenStore>(GithubTokenStore.new)
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        auth: getIt(),
        userRemoteDataSource: getIt(),
        googleSignIn: getIt(),
        githubTokenStore: getIt(),
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
  _registerInsights();
  // Notifications before projects/requests so /notify can be injected.
  _registerNotifications();
  registerProjectsDependencies(getIt);
  _registerRequests();
  _registerInboxBadges();
  _registerFcmService(onForegroundMessage, onNotificationOpened);
}

void _ensureNotificationPreferences() {
  if (getIt.isRegistered<NotificationPreferencesService>()) return;
  if (!getIt.isRegistered<SharedPreferences>() ||
      !getIt.isRegistered<FirebaseAuth>() ||
      !getIt.isRegistered<FirebaseFirestore>()) {
    return;
  }
  getIt.registerLazySingleton(
    () => NotificationPreferencesService(
      prefs: getIt(),
      auth: getIt(),
      firestore: getIt(),
    ),
  );
}

void _registerFcmService(
  void Function(String title, String body)? onForegroundMessage,
  void Function()? onNotificationOpened,
) {
  if (onForegroundMessage == null ||
      onNotificationOpened == null ||
      getIt.isRegistered<FcmService>()) {
    return;
  }

  _ensureNotificationPreferences();

  getIt.registerSingleton<FcmService>(
    FcmService(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      onForegroundMessage: onForegroundMessage,
      onNotificationOpened: onNotificationOpened,
      preferences: getIt.isRegistered<NotificationPreferencesService>()
          ? getIt<NotificationPreferencesService>()
          : null,
    ),
  );
}

void _registerMatching() {
  if (getIt.isRegistered<MatchingRepository>()) return;

  getIt
    ..registerLazySingleton<MatchingRepository>(
      () => createMatchingRepository(
        getIt<FirebaseAuth>(),
        getIt<FirebaseFirestore>(),
      ),
      dispose: (repository) => repository.dispose(),
    )
    ..registerLazySingleton<MatchingProfileRepository>(
      () => FirestoreMatchingProfileRepository(
        firestore: getIt<FirebaseFirestore>(),
        auth: getIt<FirebaseAuth>(),
      ),
    )
    ..registerLazySingleton<LikedMatchesLocalDataSource>(
      () => FirestoreLikedMatchesDataSource(
        firestore: getIt<FirebaseFirestore>(),
        auth: getIt<FirebaseAuth>(),
      ),
    )
    ..registerLazySingleton(
      () => MatchingFeedbackRemoteDataSource(
        firestore: getIt<FirebaseFirestore>(),
        auth: getIt<FirebaseAuth>(),
      ),
    )
    ..registerLazySingleton<MatchingFeedbackRepository>(
      () => MatchingFeedbackRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton(() => SaveMatchFeedback(getIt()))
    ..registerLazySingleton(() => GetRankedMatchesUseCase(getIt()))
    ..registerLazySingleton<FeedbackRepository>(
      () => FirestoreFeedbackRepository(
        firestore: getIt<FirebaseFirestore>(),
        auth: getIt<FirebaseAuth>(),
      ),
    )
    ..registerLazySingleton(() => GetUserFeedbackUseCase(getIt()))
    ..registerLazySingleton(() => GetPromptQualityMetrics(getIt()))
    ..registerLazySingleton(
      () => GetMatchingAnalyticsUseCase(
        getUserFeedback: getIt<GetUserFeedbackUseCase>(),
        profileRepository: getIt<MatchingProfileRepository>(),
        getProjects: getIt.isRegistered<GetProjects>()
            ? getIt<GetProjects>()
            : null,
      ),
    )
    ..registerFactory(
      () => MatchingCubit(
        repository: getIt<MatchingRepository>(),
        likedMatchesDataSource: getIt<LikedMatchesLocalDataSource>(),
        getRankedMatchesUseCase: getIt<GetRankedMatchesUseCase>(),
        saveMatchFeedback: getIt<SaveMatchFeedback>(),
        profileRepository: getIt<MatchingProfileRepository>(),
        getProjects: getIt.isRegistered<GetProjects>()
            ? getIt<GetProjects>()
            : null,
        getUnavailableProjectIds:
            getIt.isRegistered<GetUnavailableProjectIds>()
            ? getIt<GetUnavailableProjectIds>()
            : null,
        getUserFeedbackUseCase: getIt.isRegistered<GetUserFeedbackUseCase>()
            ? getIt<GetUserFeedbackUseCase>()
            : null,
        getMatchingAnalyticsUseCase:
            getIt.isRegistered<GetMatchingAnalyticsUseCase>()
            ? getIt<GetMatchingAnalyticsUseCase>()
            : null,
      ),
    );
}

void _registerProfile() {
  if (getIt.isRegistered<ProfileRepository>()) return;

  getIt
    ..registerLazySingleton(
      () => ProfileRemoteDataSource(auth: getIt(), firestore: getIt()),
    )
    ..registerLazySingleton(
      () => GithubProfileRemoteDataSource(
        tokenProvider: () => getIt<GithubTokenStore>().readToken(),
      ),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: getIt(),
        githubRemoteDataSource: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetProfile(getIt()))
    ..registerLazySingleton(() => UpdateProfile(getIt()))
    ..registerLazySingleton(() => SaveGithubScan(getIt()))
    ..registerLazySingleton(() => ScanGithubProfile(getIt()))
    ..registerFactory(
      () => ProfileCubit(
        getProfile: getIt(),
        updateProfile: getIt(),
        saveGithubScan: getIt(),
        scanGithubProfile: getIt(),
      ),
    );
}

void _registerInsights() {
  if (getIt.isRegistered<InsightsRepository>()) return;

  getIt
    ..registerLazySingleton(() => InsightsRemoteDataSource())
    ..registerLazySingleton<InsightsRepository>(
      () => InsightsRepositoryImpl(
        profileRemoteDataSource: getIt(),
        insightsRemoteDataSource: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetInsights(getIt()))
    ..registerFactory(() => InsightsCubit(getInsights: getIt()));
}

void _registerNotifications() {
  if (getIt.isRegistered<NotificationsRepository>()) return;

  getIt
    ..registerLazySingleton(() => NotifyRemoteDataSource(auth: getIt()))
    ..registerLazySingleton(
      () => NotificationsRemoteDataSource(
        firestore: getIt<FirebaseFirestore>(),
        auth: getIt<FirebaseAuth>(),
      ),
    )
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(remoteDataSource: getIt()),
    )
    ..registerLazySingleton(() => GetNotifications(getIt()))
    ..registerLazySingleton(() => MarkNotificationRead(getIt()))
    ..registerLazySingleton(() => WatchUnreadNotifications(getIt()))
    ..registerFactory(
      () => NotificationsCubit(
        getNotifications: getIt(),
        markNotificationRead: getIt(),
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
        notifyRemoteDataSource: getIt.isRegistered<NotifyRemoteDataSource>()
            ? getIt<NotifyRemoteDataSource>()
            : null,
      ),
    )
    ..registerLazySingleton(() => GetRequests(getIt()))
    ..registerLazySingleton(() => GetUnavailableProjectIds(getIt()))
    ..registerLazySingleton(() => UpdateRequestStatus(getIt()))
    ..registerLazySingleton(() => CreateRequest(getIt()))
    ..registerLazySingleton(() => WatchPendingReceivedRequests(getIt()))
    ..registerFactory(
      () => RequestsCubit(
        createRequest: getIt(),
        getRequests: getIt(),
        updateRequestStatus: getIt(),
      ),
    );
}

void _registerInboxBadges() {
  if (getIt.isRegistered<InboxBadgesCubit>()) return;

  getIt.registerLazySingleton(
    () => InboxBadgesCubit(
      watchUnreadNotifications: getIt(),
      watchPendingReceivedRequests: getIt(),
    ),
    dispose: (cubit) => cubit.close(),
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
