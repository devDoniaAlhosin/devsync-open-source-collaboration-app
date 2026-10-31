import 'package:devsync_open_source_collaboration_app/features/profile/presentation/screens/insights_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/screens/requests_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_animations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/ds_fade_switch.dart';
import '../core/widgets/ds_splash.dart';
import '../features/auth/presentation/screens/code_sign_in_screen.dart';
import '../features/auth/presentation/screens/email_link_sent_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/verify_code_screen.dart';
import '../features/auth/presentation/screens/verify_email_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/widgets/auth_gate.dart';
import '../features/auth/presentation/widgets/email_link_listener.dart';
import '../features/matching/presentation/screens/ai_analytics_screen.dart';
import '../features/matching/presentation/screens/ai_matching_studio_screen.dart';
import '../features/matching/presentation/screens/connect_github_screen.dart';
import '../features/matching/presentation/screens/liked_matches_screen.dart';
import '../features/matching/presentation/screens/match_feed_screen.dart';
import '../features/matching/presentation/screens/project_details_screen.dart'
    as matching_details;
import '../features/profile/data/models/profile_data.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/requests/presentation/screens/connected_celebration_screen.dart';
import '../features/requests/presentation/screens/notification_permission_screen.dart';
import '../features/projects/domain/entities/project.dart';
import '../features/projects/presentation/screens/project_details_screen.dart';
import '../features/projects/presentation/screens/projects_shell.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/shell/home_shell_screen.dart';
import '../features/shell/settings_screen.dart';
import '../features/shell/stub_screen.dart';
import 'app_routes.dart';

/// Root app — **light theme is the default**.
class DevSyncApp extends StatefulWidget {
  const DevSyncApp({super.key, this.showSplash = true});

  /// Set `false` in widget tests to skip the open animation.
  final bool showSplash;

  static _DevSyncAppState? _state;

  static ThemeMode get themeMode => _state?._themeMode ?? ThemeMode.light;

  /// Toggle light / dark from the app bar.
  static void toggleTheme() => _state?._toggleTheme();

  static void setThemeMode(ThemeMode mode) => _state?._setThemeMode(mode);

  @override
  State<DevSyncApp> createState() => _DevSyncAppState();
}

class _DevSyncAppState extends State<DevSyncApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late bool _booting;
  late bool _appVisible;

  @override
  void initState() {
    super.initState();
    DevSyncApp._state = this;
    _booting = widget.showSplash;
    _appVisible = !widget.showSplash;
    _syncSystemUi(_themeMode);
  }

  @override
  void dispose() {
    if (DevSyncApp._state == this) DevSyncApp._state = null;
    super.dispose();
  }

  void _toggleTheme() {
    _setThemeMode(
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
      _syncSystemUi(mode);
    });
  }

  void _syncSystemUi(ThemeMode mode) {
    final platformDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    final dark =
        mode == ThemeMode.dark || (mode == ThemeMode.system && platformDark);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: dark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      builder: (context, child) {
        final app = EmailLinkListener(child: child ?? const SizedBox.shrink());
        if (!widget.showSplash) return app;
        if (!_booting) return app;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (_appVisible) _LaunchReveal(child: app),
            DsSplash(
              onReveal: () {
                if (!mounted) return;
                setState(() => _appVisible = true);
                _syncSystemUi(_themeMode);
              },
              onFinished: () {
                if (!mounted) return;
                setState(() => _booting = false);
              },
            ),
          ],
        );
      },
      initialRoute: AppRoutes.intro,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  /// Named pushes use [DsFadePageRoute] (proto `motion-enter` feel).
  static Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) return null;

    final Widget? page = switch (name) {
      AppRoutes.intro => const AuthGate(),
      AppRoutes.welcome => const WelcomeScreen(),
      AppRoutes.login => const LoginScreen(),
      AppRoutes.register => const RegisterScreen(),
      AppRoutes.forgotPassword => const ForgotPasswordScreen(),
      AppRoutes.codeSignIn => const CodeSignInScreen(),
      AppRoutes.emailLinkSent => EmailLinkSentScreen(
        email: _emailArg(settings.arguments),
      ),
      AppRoutes.verifyCode => const VerifyCodeScreen(),
      AppRoutes.verifyEmail => VerifyEmailScreen(
        email: _emailArg(settings.arguments),
      ),
      AppRoutes.settings => const SettingsScreen(),
      AppRoutes.home => HomeShellScreen(
        initialIndex: settings.arguments is int
            ? settings.arguments! as int
            : 0,
      ),
      AppRoutes.feed => const MatchFeedScreen(),
      AppRoutes.likedMatches => const LikedMatchesScreen(),
      AppRoutes.connectGithub => const ConnectGithubScreen(),
      AppRoutes.editProfile => EditProfileScreen(
        data: ProfileData.sample(),
        asOnboarding: true,
      ),
      AppRoutes.analytics => const AiAnalyticsScreen(),
      AppRoutes.aiStudio => const AiMatchingStudioScreen(),
      AppRoutes.projects => const ProjectsShell(initialTab: 1),
      AppRoutes.projectDetail => _projectDetailPage(settings.arguments),
      AppRoutes.profile => const ProfileScreen(),
      AppRoutes.requests => const RequestsScreen(),
      AppRoutes.notificationPermission => NotificationPermissionScreen(
        args: settings.arguments is NotificationPermissionArgs
            ? settings.arguments! as NotificationPermissionArgs
            : const NotificationPermissionArgs(
                maintainerName: 'Karim',
                projectName: 'flutter-oss/charts',
              ),
      ),
      AppRoutes.connected => ConnectedCelebrationScreen(
        args: settings.arguments is ConnectedCelebrationArgs
            ? settings.arguments! as ConnectedCelebrationArgs
            : const ConnectedCelebrationArgs(
                collaboratorName: 'Sara',
                collaboratorInitials: 'SA',
                projectName: 'devsync-api',
              ),
      ),
      AppRoutes.discover => const ProjectsShell(initialTab: 0),
      AppRoutes.tasks => const StubScreen(
        title: 'Task board',
        owner: 'Donia',
        description: 'If-time board for collaboration tasks.',
      ),
      AppRoutes.aiInsights => const AiAnalyticsScreen(),
      AppRoutes.insights => const InsightsScreen(),
      AppRoutes.community => const StubScreen(
        title: 'Community',
        owner: 'If time',
        description: 'Community screen is planned after the core freeze.',
      ),
      AppRoutes.notifications => const NotificationsScreen(),
      _ => null,
    };

    if (page == null) return null;
    return DsFadePageRoute<dynamic>(settings: settings, builder: (_) => page);
  }

  static String? _emailArg(Object? args) {
    return args is Map ? args['email'] as String? : null;
  }

  static Widget _projectDetailPage(Object? args) {
    if (args is matching_details.ProjectDetailsArguments) {
      return matching_details.ProjectDetailsScreen(arguments: args);
    }
    if (args is Project) {
      return ProjectDetailsScreen(project: args);
    }
    return const StubScreen(
      title: 'Project detail',
      owner: 'Bishay',
      description: 'Open a project from Discover, Matches, or My projects.',
    );
  }
}

/// First-page content rises in while the splash mark is still centered.
class _LaunchReveal extends StatefulWidget {
  const _LaunchReveal({required this.child});

  final Widget child;

  @override
  State<_LaunchReveal> createState() => _LaunchRevealState();
}

class _LaunchRevealState extends State<_LaunchReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.handoff,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.emphasized,
    );
    return FadeTransition(
      opacity: motion,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(motion),
        child: widget.child,
      ),
    );
  }
}
