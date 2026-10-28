import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Shared icon widget. Defaults to Lucide sizing used in the prototype (22 dp).
///
/// Pass icons from [AppIcons] — do not use Material [Icons] in feature code.
class DsIcon extends StatelessWidget {
  const DsIcon(
    this.icon, {
    super.key,
    this.size = 22,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color ?? DevSyncPalette.of(context).textPrimary,
      semanticLabel: semanticLabel,
    );
  }
}
