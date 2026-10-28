import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ds_button.dart';
import '../../../core/widgets/ds_github_icon.dart';

class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({super.key, this.onGoogle, this.onGitHub});

  final VoidCallback? onGoogle;
  final VoidCallback? onGitHub;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DsButton(
            label: 'Google',
            icon: AppIcons.google,
            variant: DsButtonVariant.quiet,
            compact: true,
            onPressed: onGoogle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DsButton(
            label: 'GitHub',
            icon: AppIcons.github,
            variant: DsButtonVariant.quiet,
            compact: true,
            onPressed: onGitHub,
          ),
        ),
      ],
    );
  }
}

class AuthTextLink extends StatelessWidget {
  const AuthTextLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.ds.accentText;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: accent,
        minimumSize: const Size(
          AppSpacing.minTouchTarget,
          AppSpacing.minTouchTarget,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        textStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

/// Welcome header control: GitHub mark + “Sign in” in `--accent-text`.
class AuthGithubSignInLink extends StatelessWidget {
  const AuthGithubSignInLink({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = context.ds.accentText;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: accent,
        minimumSize: const Size(
          AppSpacing.minTouchTarget,
          AppSpacing.minTouchTarget,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DsGithubIcon(size: 18, color: accent),
          const SizedBox(width: 6),
          Text(
            'Sign in',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
