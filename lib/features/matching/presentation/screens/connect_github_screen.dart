import 'package:flutter/material.dart';
import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/app/devsync_app.dart';
import 'package:devsync_open_source_collaboration_app/core/icons/app_icons.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_button.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_icon.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_text_field.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/fake_github_scan_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/github_scan_result.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/github_scan_button.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/github_scan_summary_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/privacy_note_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/setup_scaffold.dart';

class ConnectGithubScreen extends StatefulWidget {
  const ConnectGithubScreen({
    super.key,
    this.initialUsername = '',
    this.onContinue,
  });

  final String initialUsername;

  final ValueChanged<GithubScanResult>? onContinue;

  @override
  State<ConnectGithubScreen> createState() => _ConnectGithubScreenState();
}

class _ConnectGithubScreenState extends State<ConnectGithubScreen> {
  final _source = const FakeGithubScanDataSource();

  static final _usernameRule = RegExp(
    r'^[a-zA-Z0-9](?:[a-zA-Z0-9]|-(?=[a-zA-Z0-9])){0,38}$',
  );

  late final TextEditingController _controller;
  GithubScanResult? _result;
  bool _scanning = false;
  String? _error;

  String get _username => _controller.text.trim();
  bool get _valid => _usernameRule.hasMatch(_username);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUsername);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    setState(() {
      _error = null;
      if (_result != null && _result!.username != _username) _result = null;
    });
  }

  Future<void> _scan() async {
    FocusScope.of(context).unfocus();
    if (!_valid) {
      setState(() => _error = 'Enter a valid GitHub username');
      return;
    }
    setState(() {
      _scanning = true;
      _error = null;
    });
    try {
      final result = await _source.scan(_username);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = "Couldn't scan this profile. Try again.");
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  void _continue() {
    final result = _result;
    if (result == null) return;
    if (widget.onContinue != null) {
      widget.onContinue!(result);
      return;
    }
    // Default onboarding: step 3 edit profile / skills → home feed.
    Navigator.of(context).pushReplacementNamed(AppRoutes.editProfile);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return SetupScaffold(
      eyebrow: 'Account setup',
      title: 'Connect GitHub',
      stepLabel: '02 / 03',
      onThemeToggle: DevSyncApp.toggleTheme,
      bottom: DsButton(
        label: 'Continue',
        onPressed: _result == null ? null : _continue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Connect your GitHub',
            style: textTheme.headlineMedium?.copyWith(
              color: ds.textPrimary,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your public repos and languages become your match profile.',
            style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          DsTextField(
            label: 'GitHub username',
            controller: _controller,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            errorText: _error,
            onChanged: _onChanged,
            onSubmitted: (_) => _scan(),
            suffix: _valid
                ? const Padding(
                    padding: EdgeInsets.only(right: AppSpacing.md),
                    child: DsIcon(
                      AppIcons.success,
                      size: 20,
                      color: AppColors.teal,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          GithubScanButton(isLoading: _scanning, onPressed: _scan),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _result == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: GithubScanSummaryCard(result: _result!),
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const PrivacyNoteCard(
            message:
                'We never read private repos or code. '
                'You can disconnect any time.',
          ),
        ],
      ),
    );
  }
}
