import 'package:flutter/material.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../../core/widgets/ds_staggered_entrance.dart';

class ExploreDevSyncItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const ExploreDevSyncItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class ExploreDevSyncSection extends StatefulWidget {
  final List<ExploreDevSyncItem> items;
  final Widget? trailing;

  const ExploreDevSyncSection({
    super.key,
    required this.items,
    this.trailing,
  });

  @override
  State<ExploreDevSyncSection> createState() => _ExploreDevSyncSectionState();
}

class _ExploreDevSyncSectionState extends State<ExploreDevSyncSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: AppAnimations.rise)
      ..forward();
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
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Explore DevSync',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ds.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'FEATURES',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ds.accentText,
                          letterSpacing: 1.1,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                widget.trailing!,
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 112,
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
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: ds.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.onTap,
        child: SizedBox(
          width: 148,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.mint.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: DsIcon(
                    item.icon,
                    size: 16,
                    color: ds.accentText,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          height: 1.2,
                          color: ds.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ds.textMuted,
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
