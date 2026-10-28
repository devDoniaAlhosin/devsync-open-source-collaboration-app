import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Greeting widget displaying the day of week and personalized welcome.
class MatchFeedGreeting extends StatelessWidget {
  const MatchFeedGreeting({super.key, this.userName = 'Nour', this.dayName});

  final String userName;
  final String? dayName;

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String get _currentDay {
    if (dayName != null) return dayName!;
    final now = DateTime.now();
    return _weekdays[now.weekday - 1];
  }

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentDay,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ds.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$_timeGreeting, $userName',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: ds.textPrimary,
              fontSize: 24,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
