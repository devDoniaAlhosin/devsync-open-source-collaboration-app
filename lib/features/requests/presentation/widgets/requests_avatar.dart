import 'package:flutter/material.dart';
import 'package:flutter_color/flutter_color.dart';

class RequestsAvatar extends StatelessWidget {
  const RequestsAvatar(this.initials, {super.key});
  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: colors.secondary.darker(60),
        ),
      ),
    );
  }
}
