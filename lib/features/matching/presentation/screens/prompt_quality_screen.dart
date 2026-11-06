import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_card.dart';

/// Screen providing prompt guidelines and preference recommendations.
class PromptQualityScreen extends StatelessWidget {
  const PromptQualityScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DsAppBar(
      title: 'Prompt guide',
      eyebrow: 'DEVSYNC',
      showBack: true,
      onBack: () => Navigator.of(context).maybePop(),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              DsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Make your preferences useful',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Describe the work you want to do, your preferred project topics, and the level of guidance you need. Keep the prompt within 1,000 characters.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Preferences guide recommendations. They do not add skills to your profile. Keep your declared skills accurate in Matching profile.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const DsCard(
                child: Text(
                  'The matching service returns project scores and reasons. It does not provide prompt-quality ratings, historical trends, or response-time analytics. Review the actual results in Match insights.',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
