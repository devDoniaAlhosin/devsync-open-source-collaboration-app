import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_animations.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/entities/collaboration_request.dart';
import 'package:flutter/material.dart';

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key, required this.item});

  final RequestItem item;

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scoreController;
  late final Animation<double> _scoreProgress;

  RequestItem get item => widget.item;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      vsync: this,
      duration: AppAnimations.score,
    );
    _scoreProgress = CurvedAnimation(
      parent: _scoreController,
      curve: AppAnimations.emphasized,
    );
    _scoreController.forward();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  bool get _canRespond =>
      item.type == RequestType.received && item.status == RequestStatus.isNew;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = DevSyncPalette.of(context);
    final hasMessage = (item.message ?? '').trim().isNotEmpty;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            _DetailsHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContributorHeader(item: item),
                    if (item.matchPercent > 0) ...[
                      const SizedBox(height: 16),
                      _MatchCard(item: item, progress: _scoreProgress),
                    ],
                    if (hasMessage) ...[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          item.message!,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 12,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _StatisticCard(
                            value: item.repositoryCount,
                            label: 'Repos',
                            progress: _scoreProgress,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatisticCard(
                            value: item.commitCount,
                            label: 'Commits',
                            progress: _scoreProgress,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatisticCard(
                            value: item.languageCount,
                            label: 'Languages',
                            progress: _scoreProgress,
                          ),
                        ),
                      ],
                    ),
                    if (item.skills.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final skill in item.skills)
                            _SkillTag(label: skill),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_canRespond)
              _DetailsActions(
                onDecline: () =>
                    Navigator.of(context).pop(RequestStatus.declined),
                onAccept: () =>
                    Navigator.of(context).pop(RequestStatus.accepted),
              )
            else
              _BackAction(onTap: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = DevSyncPalette.of(context);

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 31,
            height: 31,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: colors.onSurface,
                side: BorderSide(color: palette.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Icon(Icons.chevron_left_rounded, size: 20),
            ),
          ),
          const SizedBox(width: 9),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WORKSPACE',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Request detail',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContributorHeader extends StatelessWidget {
  const _ContributorHeader({required this.item});

  final RequestItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = DevSyncPalette.of(context);
    final subtitle = item.type == RequestType.received
        ? 'Wants to join ${item.targetName}'
        : 'You asked to join ${item.targetName}';

    return Row(
      children: [
        Container(
          width: 68,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            shape: BoxShape.circle,
          ),
          child: Text(
            item.initials,
            style: TextStyle(
              color: palette.accentText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.item, required this.progress});

  final RequestItem item;
  final Animation<double> progress;

  String get _fitLabel {
    if (item.matchPercent >= 90) return 'Great fit';
    if (item.matchPercent >= 70) return 'Good fit';
    return 'Fair fit';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = DevSyncPalette.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: progress,
                  builder: (context, child) => SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: item.matchPercent / 100 * progress.value,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      backgroundColor: palette.surfaceAlt,
                      color: palette.accentText,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: progress,
                  builder: (context, child) => Text(
                    '${(item.matchPercent * progress.value).round()}%',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fitLabel,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.matchSummary,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.value,
    required this.label,
    required this.progress,
  });

  final int value;
  final String label;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = DevSyncPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: progress,
            builder: (context, child) => Text(
              _formatCount((value * progress.value).round()),
              style: TextStyle(
                color: palette.accentText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _SkillTag extends StatelessWidget {
  const _SkillTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 9),
      ),
    );
  }
}

class _DetailsActions extends StatelessWidget {
  const _DetailsActions({required this.onDecline, required this.onAccept});

  final VoidCallback onDecline;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: onDecline,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHighest,
                  foregroundColor: colors.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Decline', style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: onAccept,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: AppColors.onTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Accept', style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackAction extends StatelessWidget {
  const _BackAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: colors.surfaceContainerHighest,
            foregroundColor: colors.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Back to requests', style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}

String _formatCount(int value) => value.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (match) => ',',
);
