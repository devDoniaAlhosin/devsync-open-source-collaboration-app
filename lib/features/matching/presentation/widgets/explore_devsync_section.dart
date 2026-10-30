import 'package:flutter/material.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_staggered_entrance.dart';

class ExploreDevSyncItem {
  final String title;

  final String subtitle;
  final VoidCallback onTap;
  const ExploreDevSyncItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

/// Horizontal carousel highlighting DevSync core capabilities.
class ExploreDevSyncSection extends StatefulWidget {
  final List<ExploreDevSyncItem> items;

  const ExploreDevSyncSection({super.key, required this.items});

  @override
  State<ExploreDevSyncSection> createState() => _ExploreDevSyncSectionState();
}

class _ExploreDevSyncSectionState extends State<ExploreDevSyncSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: AppAnimations.rise,
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final items = widget.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Text(
                'Explore DevSync',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 60),
              Text(
                'FEATURES',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ds.textMuted,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 88,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final (begin, end) = DsStaggerTiming.interval(
                index,
                items.length,
              );
              return DsStaggeredEntrance(
                animation: _entrance,
                begin: begin,
                end: end,
                child: _FeatureCard(item: items[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final ExploreDevSyncItem item;

  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Material(
      color: ds.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ds.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.onTap,
        child: Container(
          width: 136,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  color: ds.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ds.textMuted,
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
