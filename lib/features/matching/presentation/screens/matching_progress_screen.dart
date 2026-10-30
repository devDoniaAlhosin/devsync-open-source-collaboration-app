import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../widgets/matching_progress_content.dart';

export '../widgets/matching_progress_content.dart' show MatchingProgressPhase;

/// Displays progress reported by the matching operation; it owns no requests.
class MatchingProgressScreen extends StatelessWidget {
  final MatchingProgressPhase phase;

  final int? repositoryCount;
  final int? languageCount;
  final int? projectCount;
  final VoidCallback? onBack;
  const MatchingProgressScreen({
    super.key,
    this.phase = MatchingProgressPhase.readActivity,
    this.repositoryCount,
    this.languageCount,
    this.projectCount,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ds.background,
      appBar: DsAppBar(
        title: 'Finding matches',
        eyebrow: 'WORKSPACE',
        showBack: true,
        onBack: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: MatchingProgressContent(
            phase: phase,
            repositoryCount: repositoryCount,
            languageCount: languageCount,
            projectCount: projectCount,
          ),
        ),
      ),
    );
  }
}
