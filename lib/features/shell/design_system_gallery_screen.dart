import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';

/// Visual checklist of shared brand components for the team.
class DesignSystemGalleryScreen extends StatefulWidget {
  const DesignSystemGalleryScreen({super.key});

  @override
  State<DesignSystemGalleryScreen> createState() =>
      _DesignSystemGalleryScreenState();
}

class _DesignSystemGalleryScreenState extends State<DesignSystemGalleryScreen> {
  int _segment = 0;
  bool _chipSelected = true;
  final _email = TextEditingController(text: 'dev@devsync.app');

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const DsWordmark(fontSize: 22),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: DsIconButton(
              icon: AppIcons.notifications,
              showBadge: true,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const Center(child: DsLogo(height: 44)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Brand tokens + reusable components\nfrom Brand Guide & prototype v27',
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Color', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Swatch('Teal', AppColors.teal, AppColors.onTeal),
              _Swatch('Forest', AppColors.forest, AppColors.mint),
              _Swatch('Mint / splash', AppColors.mint, AppColors.forest),
              _Swatch(
                'Background',
                AppColors.lightBackground,
                AppColors.forest,
              ),
              _Swatch('Surface', AppColors.lightSurface, AppColors.forest),
              _Swatch('Border', AppColors.lightBorder, AppColors.forest),
              _Swatch('Text', AppColors.lightText, AppColors.mint),
              _Swatch('Muted', AppColors.lightMuted, AppColors.mint),
              _Swatch('Danger', AppColors.lightDanger, Colors.white),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Typography', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Text('Match. Review. Merge.', style: textTheme.displayMedium),
          Text('Figtree body — readable UI copy.', style: textTheme.bodyLarge),
          Text('Muted helper text', style: textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xxl),
          Text('Icons (Lucide · AppIcons)', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          const Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              DsIcon(AppIcons.feed, color: AppColors.teal),
              DsIcon(AppIcons.projects, color: AppColors.teal),
              DsIcon(AppIcons.requests, color: AppColors.teal),
              DsIcon(AppIcons.profile, color: AppColors.teal),
              DsIcon(AppIcons.tasks, color: AppColors.teal),
              DsIcon(AppIcons.notifications, color: AppColors.teal),
              DsIcon(AppIcons.github, color: AppColors.teal),
              DsIcon(AppIcons.back, color: AppColors.teal),
              DsIcon(AppIcons.forward, color: AppColors.teal),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Buttons', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          DsButton(label: 'Primary', onPressed: () {}),
          const SizedBox(height: 10),
          DsButton(
            label: 'Secondary',
            variant: DsButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          DsButton(
            label: 'Quiet',
            variant: DsButtonVariant.quiet,
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DsButton(
                  label: 'Danger',
                  variant: DsButtonVariant.danger,
                  onPressed: () {},
                  compact: true,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: DsButton(label: 'Disabled', compact: true)),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Fields', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          DsTextField(label: 'Email', controller: _email),
          const SizedBox(height: AppSpacing.md),
          const DsTextField(
            label: 'Password',
            obscureText: true,
            errorText: 'Password must be at least 8 characters',
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Chips & segments', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              DsChip(
                label: 'Flutter',
                selected: _chipSelected,
                onTap: () => setState(() => _chipSelected = !_chipSelected),
              ),
              const DsChip(label: 'Firebase'),
              const DsChip(label: 'Dart', variant: DsChipVariant.outline),
              const DsChip(label: 'Accepted', variant: DsChipVariant.success),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DsSegmentedControl(
            labels: const ['Pending', 'Accepted', 'Declined'],
            index: _segment,
            onChanged: (i) => setState(() => _segment = i),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Avatars & score', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              DsAvatar(initials: 'EH'),
              SizedBox(width: 12),
              DsAvatar(initials: 'SA', size: DsAvatarSize.sm),
              SizedBox(width: 12),
              DsProjectAvatar(label: 'FL'),
              Spacer(),
              DsScoreRing(score: 92),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Match card', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          DsMatchCard(
            projectName: 'flutter-oss/charts',
            subtitle: 'Needs a Dart contributor',
            score: 92,
            reason: 'Strong fit on Flutter and Firebase.',
            skills: const ['Dart', 'Firebase', 'Animation'],
            onRequest: () {},
            onSkip: () {},
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Notifications', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          const DsCard(
            child: Column(
              children: [
                DsNotificationTile(
                  title: 'New collaboration request',
                  subtitle: 'Sara wants to join your project',
                ),
                SizedBox(height: 10),
                DsNotificationTile(
                  title: 'Project update',
                  subtitle: '3 new commits on devsync-api',
                  unread: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DsBanner(
            message: 'AI matching uses a skills fallback if the model is slow.',
            onDismiss: () {},
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Empty state', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          const SizedBox(
            height: 220,
            child: DsCard(
              child: DsEmptyState(
                title: 'No matches yet',
                message: 'Complete your profile to get ranked projects.',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color, this.onColor);

  final String name;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: AppSpacing.minTouchTarget + 28,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.ds.border),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: onColor),
        ),
      ),
    );
  }
}
