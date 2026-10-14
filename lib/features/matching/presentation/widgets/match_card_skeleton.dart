import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';

/// Shimmer-style loading placeholder for a match card in the feed.
///
/// Shown while matches are being fetched from the Cloud Function.
class MatchCardSkeleton extends StatelessWidget {
  const MatchCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DsCard(
      borderRadius: AppSpacing.radiusMatch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row placeholder
          Row(
            children: [
              _placeholder(44, 44, isCircle: true),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _placeholder(double.infinity, 16),
                    const SizedBox(height: 6),
                    _placeholder(120, 12),
                  ],
                ),
              ),
              _placeholder(48, 28),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Score meter placeholder
          _placeholder(double.infinity, 8),
          const SizedBox(height: AppSpacing.md),
          // Reason box placeholder
          _placeholder(double.infinity, 56),
          const SizedBox(height: AppSpacing.md),
          // Chips placeholder
          Row(
            children: [
              _placeholder(60, 26),
              const SizedBox(width: 7),
              _placeholder(50, 26),
              const SizedBox(width: 7),
              _placeholder(70, 26),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Buttons placeholder
          Row(
            children: [
              Expanded(child: _placeholder(double.infinity, 44)),
              const SizedBox(width: 10),
              Expanded(child: _placeholder(double.infinity, 44)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder(double width, double height, {bool isCircle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.5),
        borderRadius: isCircle ? null : BorderRadius.circular(8),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
