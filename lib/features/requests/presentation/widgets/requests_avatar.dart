import 'package:flutter/material.dart';

class RequestsAvatar extends StatelessWidget {
  const RequestsAvatar(this.initials, {super.key});
  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textColor =
        Color.lerp(colors.secondary, Colors.black, 0.35) ?? colors.secondary;
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
          color: textColor,
        ),
      ),
    );
  }
}
