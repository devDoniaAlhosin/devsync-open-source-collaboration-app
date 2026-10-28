import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/ds_splash.dart';
import '../features/auth/code_sign_in_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/intro_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/verify_code_screen.dart';
import '../features/auth/welcome_screen.dart';
import '../features/matching/presentation/screens/ai_analytics_screen.dart';
import '../features/matching/presentation/screens/ai_matching_studio_screen.dart';
import '../features/matching/presentation/screens/match_feed_screen.dart';
import '../features/matching/presentation/screens/project_details_screen.dart';
import '../features/shell/design_system_gallery_screen.dart';
import '../features/shell/home_shell_screen.dart';
import '../features/shell/stub_screen.dart';
import 'app_routes.dart';

/// Root app — **light theme is the default**.
class DevSyncApp extends StatefulWidget {
  static _DevSyncAppState? _state;

  /// Set `false` in widget tests to skip the open animation.
  final bool showSplash;

  const DevSyncApp({super.key, this.showSplash = true});

  @override
  State<DevSyncApp> createState() => _DevSyncAppState();

  /// Toggle light / dark from auth chrome.
  static void toggleTheme() => _state?._toggleTheme();
}

class _DevSyncAppState extends State<DevSyncApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late bool _booting;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevSync',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      builder: (context, child) {
        if (_booting) {
          return DsSplash(
            onFinished: () {
              if (!mounted) return;
              setState(() => _booting = false);
            },
          );
        }
        return child ?? const SizedBox.shrink();
      },
      initialRoute: AppRoutes.intro,
      routes: {
        AppRoutes.intro: (_) => const IntroScreen(),
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.codeSignIn: (_) => const CodeSignInScreen(),
        AppRoutes.verifyCode: (_) => const VerifyCodeScreen(),
        AppRoutes.designSystem: (_) => const DesignSystemGalleryScreen(),
        AppRoutes.home: (_) => const HomeShellScreen(),
        AppRoutes.feed: (_) => const MatchFeedScreen(),
        AppRoutes.analytics: (_) => const AiAnalyticsScreen(),
        AppRoutes.aiStudio: (_) => const AiMatchingStudioScreen(),
        AppRoutes.projects: (_) =>
            const StubScreen(title: 'Projects', owner: 'Bishay'),
        AppRoutes.profile: (_) => const StubScreen(
          title: 'Profile',
          owner: 'Saga',
          description: 'Skills, bio, and GitHub activity.',
        ),
        AppRoutes.requests: (_) =>
            const StubScreen(title: 'Collaboration requests', owner: 'Yousef'),
      },
      onGenerateRoute: (settings) {
        if (settings.name != AppRoutes.projectDetail) return null;
        final arguments = settings.arguments;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProjectDetailsScreen(
            arguments: arguments is ProjectDetailsArguments ? arguments : null,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (DevSyncApp._state == this) DevSyncApp._state = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    DevSyncApp._state = this;
    _booting = widget.showSplash;
    _syncSystemUi(_themeMode);
  }

  void _syncSystemUi(ThemeMode mode) {
    final dark = mode == ThemeMode.dark;
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

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      _syncSystemUi(_themeMode);
    });
  }
}
