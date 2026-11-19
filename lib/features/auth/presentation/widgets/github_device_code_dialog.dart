import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../../core/widgets/ds_toast.dart';

/// Device-code sheet. Stays open while GitHub authorizes; returns `false` on cancel.
Future<bool?> showGitHubDeviceCodeDialog(
  BuildContext context, {
  required String userCode,
  required String verificationUri,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => GitHubDeviceCodeDialog(
      userCode: userCode,
      verificationUri: verificationUri,
    ),
  );
}

class GitHubDeviceCodeDialog extends StatelessWidget {
  const GitHubDeviceCodeDialog({
    super.key,
    required this.userCode,
    required this.verificationUri,
  });

  final String userCode;
  final String verificationUri;

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: userCode));
    if (!context.mounted) return;
    showDsToast(
      context,
      'Code copied — paste it on GitHub',
      tone: DsToastTone.success,
    );
  }

  Future<void> _openGitHub(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: userCode));
    final uri = Uri.tryParse(verificationUri);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!context.mounted) return;
    showDsToast(
      context,
      'Paste the code on GitHub if asked, then wait here',
      tone: DsToastTone.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = DevSyncPalette.of(context);

    return AlertDialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      title: Text('Connect GitHub', style: textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Open GitHub, enter this code, then come back — we finish automatically.',
            style: textTheme.bodyMedium?.copyWith(color: context.ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    userCode,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy code',
                  onPressed: () => _copyCode(context),
                  icon: DsIcon(AppIcons.copy, color: context.ds.accentText),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Waiting for GitHub…',
                  style: textTheme.bodySmall?.copyWith(
                    color: context.ds.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          DsButton(
            label: 'Open GitHub',
            icon: AppIcons.externalLink,
            onPressed: () => _openGitHub(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          DsButton(
            label: 'Copy code',
            variant: DsButtonVariant.secondary,
            icon: AppIcons.copy,
            onPressed: () => _copyCode(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          DsButton(
            label: 'Cancel',
            variant: DsButtonVariant.quiet,
            leading: DsIcon(AppIcons.close, color: context.ds.textMuted),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
