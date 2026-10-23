import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.value,
    required this.label,
    this.highlight = true,
    super.key,
  });

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: context.ds.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ds.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.displaySmall.copyWith(
                fontSize: 28,
                color: highlight ? AppColors.teal : context.ds.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.ds.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
