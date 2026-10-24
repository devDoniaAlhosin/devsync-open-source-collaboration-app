import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/devsync_app.dart';
import '../../core/constants/app_assets.dart';
import '../../core/di/injection.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_app_bar.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_card.dart';
import '../../core/widgets/ds_icon.dart';
import '../../core/widgets/ds_info_row.dart';
import '../../core/widgets/ds_segmented_control.dart';
import '../../core/widgets/ds_text_field.dart';
import '../../core/widgets/ds_toggle.dart';
import '../auth/presentation/cubit/auth_cubit.dart';

/// Prototype screen 21. Settings — Donia.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifyRequests = true;
  bool _notifyMatches = true;
  bool _notifyTasks = false;
  int _flavor = 0;

  int get _themeIndex => switch (DevSyncApp.themeMode) {
        ThemeMode.system => 0,
        ThemeMode.dark => 1,
        ThemeMode.light => 2,
      };

  bool get _isPro => _flavor == 1;

  Future<void> _signOut() async {
    await getIt<AuthCubit>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.intro,
      (route) => false,
    );
  }

  void _confirmDelete() {
    final confirm = TextEditingController();
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x9E050F0E),
      builder: (context) {
        final ds = context.ds;
        final textTheme = Theme.of(context).textTheme;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final canDelete = confirm.text.trim() == 'DELETE';
            return Dialog(
              backgroundColor: ds.background,
              insetPadding: const EdgeInsets.symmetric(horizontal: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMatch),
                side: BorderSide(color: ds.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: ds.danger,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      alignment: Alignment.center,
                      child: DsIcon(AppIcons.trash, color: AppColors.forest),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Delete your account?',
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'This removes your profile, skills and requests. It can’t be undone.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: ds.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DsTextField(
                      label: 'Type DELETE to confirm',
                      controller: confirm,
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DsButton(
                      label: 'Delete account',
                      variant: DsButtonVariant.dangerFilled,
                      onPressed: canDelete
                          ? () {
                              Navigator.of(context).pop();
                              _signOut();
                            }
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DsButton(
                      label: 'Keep my account',
                      variant: DsButtonVariant.quiet,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(confirm.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: DsAppBar(
        title: 'Settings',
        eyebrow: 'WORKSPACE',
        onThemeToggle: DevSyncApp.toggleTheme,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const _Sec('Appearance'),
          const SizedBox(height: AppSpacing.sm),
          DsSegmentedControl(
            labels: const ['System', 'Dark', 'Light'],
            index: _themeIndex,
            onChanged: (i) {
              DevSyncApp.setThemeMode(switch (i) {
                0 => ThemeMode.system,
                1 => ThemeMode.dark,
                _ => ThemeMode.light,
              });
              setState(() {});
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const _Sec('Notifications'),
          const SizedBox(height: AppSpacing.sm),
          DsCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                DsInfoRow(
                  icon: AppIcons.users,
                  title: 'Requests and replies',
                  showDivider: true,
                  trailing: DsToggle(
                    value: _notifyRequests,
                    semanticLabel: 'Requests',
                    onChanged: (v) => setState(() => _notifyRequests = v),
                  ),
                ),
                DsInfoRow(
                  icon: AppIcons.zap,
                  title: 'New matches',
                  showDivider: true,
                  trailing: DsToggle(
                    value: _notifyMatches,
                    semanticLabel: 'Matches',
                    onChanged: (v) => setState(() => _notifyMatches = v),
                  ),
                ),
                DsInfoRow(
                  icon: AppIcons.success,
                  title: 'Task changes',
                  trailing: DsToggle(
                    value: _notifyTasks,
                    semanticLabel: 'Tasks',
                    onChanged: (v) => setState(() => _notifyTasks = v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _Sec('App build'),
          const SizedBox(height: AppSpacing.sm),
          DsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        _isPro ? AppAssets.appIcon : AppAssets.appIconTeal,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        semanticLabel: _isPro ? 'DevSync Pro' : 'DevSync Free',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isPro ? 'DevSync Pro' : 'DevSync Free',
                            style: textTheme.titleMedium,
                          ),
                          Text(
                            _isPro
                                ? 'Teal card, dark icon'
                                : 'Dark card, teal icon',
                            style: textTheme.bodySmall?.copyWith(
                              color: ds.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DsSegmentedControl(
                  labels: const ['Free', 'Pro'],
                  index: _flavor,
                  onChanged: (i) => setState(() => _flavor = i),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DsCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                DsInfoRow(
                  icon: AppIcons.chart,
                  title: 'Prompt quality',
                  subtitle: 'Relevance by version',
                  showDivider: true,
                  trailing: DsIcon(
                    AppIcons.chevronRight,
                    color: ds.textMuted,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Prompt quality is an if-time screen'),
                      ),
                    );
                  },
                ),
                DsInfoRow(
                  icon: AppIcons.shield,
                  title: 'Privacy',
                  subtitle: 'Public GitHub data only',
                  trailing: DsIcon(
                    AppIcons.chevronRight,
                    color: ds.textMuted,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'We only use public GitHub activity to suggest projects.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          DsButton(
            label: 'Sign out',
            icon: AppIcons.signOut,
            variant: DsButtonVariant.quiet,
            onPressed: _signOut,
          ),
          const SizedBox(height: AppSpacing.md),
          DsButton(
            label: 'Delete account and data',
            icon: AppIcons.trash,
            variant: DsButtonVariant.danger,
            onPressed: _confirmDelete,
          ),
        ],
      ),
    );
  }
}

class _Sec extends StatelessWidget {
  const _Sec(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: context.ds.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
    );
  }
}
