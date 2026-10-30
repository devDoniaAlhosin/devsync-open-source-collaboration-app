import 'package:devsync_open_source_collaboration_app/core/theme/app_animations.dart';
import 'package:flutter/material.dart';

/// Inbox filter: All / Received / Sent on a light rounded track.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const _labels = ['All', 'Received', 'Sent'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = theme.textTheme.labelLarge!;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / _labels.length;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: AppAnimations.normal,
                curve: AppAnimations.emphasized,
                left: segmentWidth * index,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                children: List.generate(_labels.length, (i) {
                  final selected = i == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(i),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: AppAnimations.fast,
                          curve: AppAnimations.standard,
                          style: label.copyWith(
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? colors.onPrimary
                                : colors.onSurfaceVariant,
                          ),
                          child: Text(_labels[i]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
