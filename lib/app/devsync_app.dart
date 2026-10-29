import 'package:devsync_open_source_collaboration_app/features/profile/presentation/screens/insights_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_animations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/ds_splash.dart';
import '../features/auth/presentation/pages/code_sign_in_screen.dart';
import '../features/auth/presentation/pages/email_link_sent_screen.dart';
import '../features/auth/presentation/pages/forgot_password_screen.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/register_screen.dart';
import '../features/auth/presentation/pages/verify_code_screen.dart';
import '../features/auth/presentation/pages/verify_email_screen.dart';
import '../features/auth/presentation/pages/welcome_screen.dart';
import '../features/auth/presentation/widgets/auth_gate.dart';
import '../features/auth/presentation/widgets/email_link_listener.dart';
import '../features/projects/data/project_repository.dart';
import '../features/projects/models/project_model.dart';
import '../features/projects/screens/project_details_screen.dart';
import '../features/projects/screens/projects_shell.dart';
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
      routes: {
        AppRoutes.intro: (_) => const AuthGate(),
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.codeSignIn: (_) => const CodeSignInScreen(),
        AppRoutes.emailLinkSent: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final email = args is Map ? args['email'] as String? : null;
          return EmailLinkSentScreen(email: email);
        },
        AppRoutes.verifyCode: (_) => const VerifyCodeScreen(),
        AppRoutes.verifyEmail: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final email = args is Map ? args['email'] as String? : null;
          return VerifyEmailScreen(email: email);
        },
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.home: (_) => const HomeShellScreen(),
        AppRoutes.feed: (_) => const StubScreen(
          title: 'Match feed',
          owner: 'Emad',
          description: 'Ranked AI match feed with score meter and reason.',
        ),
        AppRoutes.projects: (_) => const ProjectsShell(),
        AppRoutes.projectDetail: (context) {
          final project = ModalRoute.of(context)?.settings.arguments;
          if (project is! ProjectModel) {
            return const StubScreen(
              title: 'Project detail',
              owner: 'Bishay',
              description:
                  'Open a project from Discover or My projects to view its details.',
            );
          }
          return ProjectDetailsScreen(
            project: project,
            stats: ProjectRepository.statsFor(project.id),
          );
        },
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.requests: (_) =>
            const StubScreen(title: 'Collaboration requests', owner: 'Yousef'),
        AppRoutes.discover: (_) => const ProjectsShell(),
        AppRoutes.tasks: (_) => const StubScreen(
          title: 'Task board',
          owner: 'Donia',
          description: 'If-time board for collaboration tasks.',
        ),
        AppRoutes.aiStudio: (_) => const StubScreen(
          title: 'AI Studio',
          owner: 'Emad',
          description: 'Prompt studio for matching quality.',
        ),
        AppRoutes.aiInsights: (_) => const StubScreen(
          title: 'AI analytics',
          owner: 'Emad',
          description: 'If-time quality analytics.',
        ),
        AppRoutes.insights: (_) => const InsightsScreen(),
        AppRoutes.community: (_) => const StubScreen(
          title: 'Community',
          owner: 'If time',
          description: 'Community screen is planned after the core freeze.',
        ),
        AppRoutes.notifications: (_) => const StubScreen(
          title: 'Notifications',
          owner: 'Yousef',
          description: 'Alerts for requests, matches, and tasks.',
        ),
      },
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
