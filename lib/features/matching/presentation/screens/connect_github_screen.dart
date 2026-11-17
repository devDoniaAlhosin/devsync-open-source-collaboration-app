import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_card.dart';
import '../cubit/matching_cubit.dart';

/// Screen for editing declared matching skills and GitHub settings.
class ConnectGithubScreen extends StatefulWidget {
  const ConnectGithubScreen({super.key, this.cubit});

  final MatchingCubit? cubit;

  @override
  State<ConnectGithubScreen> createState() => _ConnectGithubScreenState();
}

class _ConnectGithubScreenState extends State<ConnectGithubScreen> {
  late final MatchingCubit _cubit;
  late final bool _ownsCubit;
  final _skillsController = TextEditingController();
  bool _edited = false;

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = widget.cubit ?? getIt<MatchingCubit>();
    _skillsController.text = _cubit.state.profile.declaredSkills.join(', ');
    if (_ownsCubit) _cubit.loadInitialData();
  }

  @override
  void dispose() {
    _skillsController.dispose();
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final skills = _skillsController.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toSet()
        .toList();
    final saved = await _cubit.saveDeclaredSkills(skills);
    if (!mounted) return;
    if (saved) _edited = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Skills saved. Your matches have been refreshed.'
              : _cubit.state.actionErrorMessage ??
                    'Could not save your skills. Try again.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DsAppBar(
      title: 'Matching profile',
      eyebrow: 'DEVSYNC',
      showBack: true,
      onBack: () => Navigator.of(context).maybePop(),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: BlocConsumer<MatchingCubit, MatchingState>(
            bloc: _cubit,
            listener: (context, state) {
              if (!_edited) {
                _skillsController.text = state.profile.declaredSkills.join(
                  ', ',
                );
              }
            },
            builder: (context, state) {
              final profile = state.profile;
              final busy =
                  state.isLoading || state.isGenerating || state.isSaving;
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                children: [
                  Text(
                    'Skills for matching',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'List the skills you want to contribute. These are saved to your account and sent to the matching service.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _skillsController,
                    enabled: !busy,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 2000,
                    onChanged: (_) => _edited = true,
                    decoration: const InputDecoration(
                      labelText: 'Your skills',
                      hintText: 'Separate each skill with a comma',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DsButton(
                    label: 'Save skills',
                    isLoading: state.isSaving,
                    onPressed: busy ? null : _save,
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(state.errorMessage!),
                    TextButton(
                      onPressed: busy ? null : _cubit.loadInitialData,
                      child: const Text('Retry loading profile and matches'),
                    ),
                  ],
                  if (busy)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  DsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recorded GitHub data',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (profile.githubUrl?.isNotEmpty == true)
                          SelectableText(profile.githubUrl!),
                        if (profile.githubLanguages.isNotEmpty)
                          Text(
                            'Languages: ${profile.githubLanguages.keys.join(', ')}',
                          ),
                        if (profile.publicRepoCount > 0)
                          Text(
                            'Public repositories: ${profile.publicRepoCount}',
                          ),
                        if (profile.totalContributions > 0)
                          Text('Contributions: ${profile.totalContributions}'),
                        if (profile.topRepositories.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          for (final repository in profile.topRepositories)
                            SelectableText(repository),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'This shows public GitHub data already saved to your account. GitHub linking and live scans are not available here. You can find matches using your declared skills.',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
