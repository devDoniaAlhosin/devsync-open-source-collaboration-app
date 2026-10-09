import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/shell/design_system_gallery_screen.dart';
import '../features/shell/home_shell_screen.dart';
import '../features/shell/stub_screen.dart';
import 'app_routes.dart';

class DevSyncApp extends StatelessWidget {
  const DevSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      initialRoute: AppRoutes.welcome,
      routes: {
        AppRoutes.welcome: (_) => const WelcomeStubScreen(),
        AppRoutes.designSystem: (_) => const DesignSystemGalleryScreen(),
        AppRoutes.home: (_) => const HomeShellScreen(),
        AppRoutes.login: (_) => const StubScreen(
              title: 'Sign in',
              owner: 'Donia',
              description: 'Welcome / login / register / password reset.',
            ),
        AppRoutes.register: (_) => const StubScreen(
              title: 'Register',
              owner: 'Donia',
            ),
        AppRoutes.feed: (_) => const StubScreen(
              title: 'Match feed',
              owner: 'Emad',
              description: 'Ranked AI match feed with score meter and reason.',
            ),
        AppRoutes.projects: (_) => const StubScreen(
              title: 'Projects',
              owner: 'Bishay',
            ),
        AppRoutes.projectDetail: (_) => const StubScreen(
              title: 'Project detail',
              owner: 'Bishay',
            ),
        AppRoutes.profile: (_) => const StubScreen(
              title: 'Profile',
              owner: 'Saga',
              description: 'Skills, bio, and GitHub activity.',
            ),
        AppRoutes.requests: (_) => const StubScreen(
              title: 'Collaboration requests',
              owner: 'Yousef',
            ),
        AppRoutes.tasks: (_) => const StubScreen(
              title: 'Task board',
              owner: 'Donia',
              description: 'If-time feature — start after core freeze.',
            ),
      },
    );
  }
}
