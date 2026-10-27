import 'package:devsync_open_source_collaboration_app/features/requests/presentation/widgets/request_card.dart';
import 'package:flutter/material.dart';

class TeamMessagesButton extends StatelessWidget {
  const TeamMessagesButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: cardDecoration(context),
      alignment: Alignment.center,
      child: Text(
        'Team messages →',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
