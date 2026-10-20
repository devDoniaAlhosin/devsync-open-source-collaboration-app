import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';

class MatchCardSkeleton extends StatelessWidget {
  const MatchCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DsCard(
      borderRadius: AppSpacing.radiusMatch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _placeholder(context, 44, 44, isCircle: true),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _placeholder(context, double.infinity, 16),
                    const SizedBox(height: 6),
                    _placeholder(context, 120, 12),
                  ],
                ),
              ),
              _placeholder(context, 48, 28),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _placeholder(context, double.infinity, 8),
          const SizedBox(height: AppSpacing.md),
          _placeholder(context, double.infinity, 56),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _placeholder(context, 60, 26),
              const SizedBox(width: 7),
              _placeholder(context, 50, 26),
              const SizedBox(width: 7),
              _placeholder(context, 70, 26),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _placeholder(context, double.infinity, 44)),
              const SizedBox(width: 10),
              Expanded(child: _placeholder(context, double.infinity, 44)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder(
    BuildContext context,
    double width,
    double height, {
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.ds.surfaceAlt.withValues(alpha: 0.5),
        borderRadius: isCircle ? null : BorderRadius.circular(8),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
