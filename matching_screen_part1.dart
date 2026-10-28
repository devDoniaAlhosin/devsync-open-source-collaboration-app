import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF4F2ED);
  static const card = Color(0xFFFFFEFC);
  static const mint = Color(0xFF22C7B2);
  static const teal = Color(0xFF079D90);
  static const ink = Color(0xFF21383A);
  static const muted = Color(0xFF829394);
  static const border = Color(0xFFE6E3DB);
  static const chip = Color(0xFFE8E4DD);
  static const mintLight = Color(0xFFE3F7F2);
}

class Match {
  final String name;
  final int score;
  final String description;
  const Match(this.name, this.score, this.description);
}

const demoMatches = <Match>[
  Match('flutter-oss/charts', 92,
      'Strong Flutter UI and animation overlap. Active maintainer seeking chart transitions.'),
  Match('nova-tools/cli', 86,
      'Testing and documentation tasks align with your recent work.'),
  Match('firebase-kit/auth', 81,
      'Auth and Firestore rules are relevant to your GitHub skills.'),
];

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _preferences = TextEditingController(
    text: 'Find beginner-friendly Flutter or Firebase projects where I can help '
        'with UI, animations, testing, and documentation. Prefer active maintainers.',
  );
  int _selectedTab = 0;
  bool _analytics = false;
  bool _generated = false;
  String _priority = 'Skills';

  @override
  void dispose() {
    _preferences.dispose();
    super.dispose();
  }

  void _switchToAnalytics() {
    setState(() {
      _selectedTab = 0;
      _analytics = true;
    });
  }

  void _switchToMatches() {
    setState(() {
      _selectedTab = 0;
      _analytics = false;
    });
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _refine() {
    const promptByPriority = <String, String>{
      'Skills': 'Prioritize projects matching my Flutter, Firebase, UI, '
          'animation, and testing skills. Prefer beginner-friendly issues and active maintainers.',
      'Beginner-friendly': 'Prioritize beginner-friendly, well-documented '
          'Flutter or Firebase issues with clear steps and responsive maintainers.',
      'Recent activity': 'Prioritize Flutter and Firebase repositories '
          'with recent commits, active maintainers, and open issues that match my skills.',
    };
    _preferences.text = promptByPriority[_priority] ?? _preferences.text;
    _switchToMatches();
    _notify('Demo prompt refined for $_priority');
  }
}
