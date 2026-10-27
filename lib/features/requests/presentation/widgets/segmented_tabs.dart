import 'package:devsync_open_source_collaboration_app/core/theme/app_animations.dart';
import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: 44,
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment: Alignment(-1.0 + index, 0),
                  duration: AppAnimations.normal,
                  curve: AppAnimations.emphasized,
                  child: Container(
                    width: constraints.maxWidth / _labels.length,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(12),
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
                        child: SizedBox(
                          height: 44,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: AppAnimations.fast,
                              curve: AppAnimations.standard,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                              ),
                              child: Text(_labels[i]),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
