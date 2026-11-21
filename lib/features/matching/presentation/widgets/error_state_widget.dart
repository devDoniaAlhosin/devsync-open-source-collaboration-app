import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../domain/failures/matching_failures.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({required this.failure, this.onRetry, super.key});

  final MatchingFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconForFailure(failure), size: 64, color: ds.textMuted),
            const SizedBox(height: AppSpacing.lg),

            Text(
              failure.userMessage,
              style: textTheme.bodyLarge?.copyWith(color: ds.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            if (onRetry != null &&
                failure is! ProfileIncompleteFailure &&
                failure is! AuthFailure)
              DsButton(
                label: 'Retry',
                onPressed: onRetry,
                icon: AppIcons.refresh,
              )
            else if (failure is ProfileIncompleteFailure)
              DsButton(
                label: 'Go to Profile',
                onPressed: () {
                  Navigator.of(context).pushNamed('/profile');
                },
                icon: AppIcons.user,
              )
            else if (failure is AuthFailure)
              DsButton(
                label: 'Sign In',
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/welcome', (route) => false);
                },
                icon: AppIcons.logIn,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFailure(MatchingFailure failure) {
    return switch (failure) {
      NetworkFailure() => AppIcons.wifiOff,
      AuthFailure() => AppIcons.lock,
      RateLimitFailure() => AppIcons.clock,
      ServerFailure() => AppIcons.alertTriangle,
      NoMatchesFailure() => AppIcons.search,
      ProfileIncompleteFailure() => AppIcons.user,
      ValidationFailure() => AppIcons.alertCircle,
      UnknownFailure() => AppIcons.alertTriangle,
    };
  }
}
