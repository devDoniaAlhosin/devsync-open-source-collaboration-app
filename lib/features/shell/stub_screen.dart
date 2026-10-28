import 'package:material_ui/material_ui.dart';

import '../../core/icons/app_icons.dart';
import '../../core/widgets/ds_empty_state.dart';

/// Temporary screen until the feature owner lands real UI.
class StubScreen extends StatelessWidget {
  const StubScreen({
    super.key,
    required this.title,
    required this.owner,
    this.description,
  });

  final String title;
  final String owner;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: DsEmptyState(
        icon: AppIcons.construction,
        title: '$title (stub)',
        message:
            description ??
            'Owned by $owner. Replace this stub with the real screen.',
        actionLabel: 'Back',
        onAction: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
