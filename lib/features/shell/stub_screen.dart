import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_empty_state.dart';

/// Temporary screen until the feature owner lands real UI.
class StubScreen extends StatelessWidget {
  const StubScreen({
    super.key,
    required this.title,
    required this.owner,
    this.description,
  });

  final String title;
  final String owner;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: DsEmptyState(
        icon: Icons.construction_outlined,
        title: '$title (stub)',
        message: description ??
            'Owned by $owner. Replace this stub with the real screen.',
        actionLabel: 'Back',
        onAction: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}

/// Landing / welcome stub with navigation into feature stubs and the
/// design-system gallery so the whole team can preview shared widgets.
class WelcomeStubScreen extends StatelessWidget {
  const WelcomeStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text('DevSync', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Code with the right people.',
                style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              DsButton(
                label: 'Design system gallery',
                expanded: true,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.designSystem),
              ),
              const SizedBox(height: AppSpacing.md),
              DsButton(
                label: 'Sign in (stub)',
                variant: DsButtonVariant.secondary,
                expanded: true,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.login),
              ),
              const SizedBox(height: AppSpacing.md),
              DsButton(
                label: 'Explore stubs',
                variant: DsButtonVariant.ghost,
                expanded: true,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.home),
              ),
              const Spacer(),
              Text(
                'Shared theme + widgets ready for feature owners.',
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
