import 'package:devsync_open_source_collaboration_app/core/icons/app_icons.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_app_bar.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_card.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_empty_state.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_icon.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_page_fade.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_page_header.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/entities/profile.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/language_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum GithubStatKind { repos, commits, languages }

/// List detail for a tapped profile stat (repos / commits / languages).
class GithubStatsListScreen extends StatelessWidget {
  const GithubStatsListScreen({
    super.key,
    required this.kind,
    required this.profile,
  });

  final GithubStatKind kind;
  final Profile profile;

  String get _title => switch (kind) {
    GithubStatKind.repos => 'Repositories',
    GithubStatKind.commits => 'Commits',
    GithubStatKind.languages => 'Languages',
  };

  String get _meta => switch (kind) {
    GithubStatKind.repos => '${profile.repos} public',
    GithubStatKind.commits => '${profile.commits} this year',
    GithubStatKind.languages => '${profile.languages.length} detected',
  };

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Scaffold(
      backgroundColor: ds.background,
      appBar: DsAppBar(
        title: _title,
        eyebrow: 'GITHUB',
        showBack: true,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: DsPageFade(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.sm,
            AppSpacing.screenPadding,
            AppSpacing.xxxl,
          ),
          children: [
            DsPageHeader(
              style: DsPageHeaderStyle.page,
              title: _title,
              eyebrow: _meta,
              body: switch (kind) {
                GithubStatKind.repos =>
                  'Top public repos from your connected GitHub profile.',
                GithubStatKind.commits =>
                  'Weekly activity from your contribution calendar.',
                GithubStatKind.languages =>
                  'Tap a language for estimated repos, commits, and activity.',
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            ...switch (kind) {
              GithubStatKind.repos => _repoTiles(context),
              GithubStatKind.commits => _commitTiles(context),
              GithubStatKind.languages => _languageTiles(context),
            },
          ],
        ),
      ),
    );
  }

  List<Widget> _repoTiles(BuildContext context) {
    final repos = profile.topRepositories;
    if (repos.isEmpty) {
      return [
        DsEmptyState(
          icon: AppIcons.github,
          title: 'No repo names saved yet',
          message: profile.repos > 0
              ? 'You have ${profile.repos} public repos. Re-scan GitHub from Edit profile to load names.'
              : 'Connect GitHub and scan to see repositories here.',
        ),
      ];
    }

    return [
      for (var i = 0; i < repos.length; i++) ...[
        if (i > 0) const SizedBox(height: AppSpacing.sm),
        _StatRow(
          leading: DsIcon(AppIcons.projects, color: AppColors.teal, size: 20),
          title: _repoName(repos[i]),
          subtitle: repos[i],
          onTap: () => _openUrl(repos[i]),
        ),
      ],
    ];
  }

  List<Widget> _commitTiles(BuildContext context) {
    final weeks = _activeWeeks(profile.activity);
    if (weeks.isEmpty) {
      return [
        const DsEmptyState(
          icon: AppIcons.chart,
          title: 'No activity yet',
          message: 'Contribution weeks will show here after a GitHub scan.',
        ),
      ];
    }

    return [
      for (var i = 0; i < weeks.length; i++) ...[
        if (i > 0) const SizedBox(height: AppSpacing.sm),
        _StatRow(
          leading: DsIcon(AppIcons.chart, color: AppColors.teal, size: 20),
          title: weeks[i].label,
          subtitle: weeks[i].subtitle,
        ),
      ],
    ];
  }

  List<Widget> _languageTiles(BuildContext context) {
    final languages = profile.languages;
    if (languages.isEmpty) {
      return [
        const DsEmptyState(
          icon: AppIcons.code,
          title: 'No languages yet',
          message: 'Connect GitHub and scan to see your language mix.',
        ),
      ];
    }

    return [
      for (var i = 0; i < languages.length; i++) ...[
        if (i > 0) const SizedBox(height: AppSpacing.sm),
        _StatRow(
          leading: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Color(languages[i].colorArgb),
              shape: BoxShape.circle,
            ),
          ),
          title: languages[i].name,
          subtitle: '${languages[i].percent}% of scanned code',
          onTap: () => LanguageDetailSheet.show(
            context,
            language: languages[i],
            profile: profile,
          ),
        ),
      ],
    ];
  }

  static String _repoName(String urlOrName) {
    final parts = urlOrName
        .split('/')
        .where((p) => p.isNotEmpty)
        .toList(growable: false);
    return parts.isEmpty ? urlOrName : parts.last;
  }

  static Future<void> _openUrl(String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    final uri = Uri.tryParse(
      trimmed.startsWith('http') ? trimmed : 'https://$trimmed',
    );
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static List<_WeekSummary> _activeWeeks(List<List<int>> activity) {
    if (activity.isEmpty) return const [];
    final out = <_WeekSummary>[];
    final total = activity.length;
    for (var w = 0; w < total; w++) {
      final week = activity[w];
      var activeDays = 0;
      var intensity = 0;
      for (final day in week) {
        if (day > 0) {
          activeDays++;
          intensity += day;
        }
      }
      if (activeDays == 0) continue;
      final weeksAgo = total - 1 - w;
      final label = weeksAgo == 0
          ? 'This week'
          : weeksAgo == 1
          ? '1 week ago'
          : '$weeksAgo weeks ago';
      out.add(
        _WeekSummary(
          label: label,
          subtitle: '$activeDays active days · intensity $intensity',
        ),
      );
    }
    // Newest first for a feed-like list.
    return out.reversed.toList(growable: false);
  }
}

class _WeekSummary {
  const _WeekSummary({required this.label, required this.subtitle});

  final String label;
  final String subtitle;
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: DsCard(
          tone: DsCardTone.inset,
          borderRadius: AppSpacing.radiusLg,
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        color: ds.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                DsIcon(AppIcons.chevronRight, color: ds.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
