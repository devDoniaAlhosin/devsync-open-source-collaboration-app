import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum DsAvatarSize { sm, md, lg }

/// Initials / image avatar (prototype `.av`).
class DsAvatar extends StatelessWidget {
  const DsAvatar({
    super.key,
    this.initials,
    this.imageUrl,
    this.size = DsAvatarSize.md,
  });

  final String? initials;
  final String? imageUrl;
  final DsAvatarSize size;

  double get _diameter => switch (size) {
    DsAvatarSize.sm => 40,
    DsAvatarSize.md => AppSpacing.avatar,
    DsAvatarSize.lg => AppSpacing.avatarLg,
  };

  double get _fontSize => switch (size) {
    DsAvatarSize.sm => 14,
    DsAvatarSize.md => 15,
    DsAvatarSize.lg => 30,
  };

  @override
  Widget build(BuildContext context) {
    final label = (initials ?? '?').toUpperCase();
    final ds = context.ds;

    return Container(
      width: _diameter,
      height: _diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ds.surfaceAlt,
        shape: BoxShape.circle,
        border: Border.all(color: ds.border),
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl != null
          ? null
          : Text(
              label.length > 2 ? label.substring(0, 2) : label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.teal,
                fontSize: _fontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

/// Squared project / repo mark (prototype `.pa`) — intentional dark panel.
class DsProjectAvatar extends StatelessWidget {
  const DsProjectAvatar({super.key, required this.label, this.large = false});

  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 76.0 : 52.0;
    final radius = large ? AppSpacing.radiusXl : 16.0;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Text(
        label.length > 2
            ? label.substring(0, 2).toUpperCase()
            : label.toUpperCase(),
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppColors.teal,
          fontSize: large ? 24 : 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
