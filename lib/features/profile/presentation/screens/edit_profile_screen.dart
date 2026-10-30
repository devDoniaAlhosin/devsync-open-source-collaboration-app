import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/core/icons/app_icons.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_app_bar.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_button.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_card.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_icon.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_staggered_entrance.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_text_field.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/data/models/profile_data.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/github_connection_card.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/skills_editor.dart';
import 'package:flutter/material.dart';

class EditProfileResult {
  const EditProfileResult({required this.bio, required this.skills});

  final String bio;
  final List<String> skills;
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.data,
    this.asOnboarding = false,
  });

  final ProfileData data;

  /// When true (post Connect GitHub), save clears the stack to Home / Matches.
  final bool asOnboarding;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const int _bioLimit = 140;

  late final TextEditingController _bio;
  late final List<String> _available;
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _bio = TextEditingController(text: widget.data.bio);
    _selected = {...widget.data.skills};
    _available = [
      ...widget.data.skills,
      for (final s in widget.data.suggestedSkills)
        if (!widget.data.skills.contains(s)) s,
    ];
  }

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  void _toggle(String skill) {
    setState(() {
      if (!_selected.remove(skill)) _selected.add(skill);
    });
  }

  void _add(String name) {
    final existing = _available.indexWhere(
      (s) => s.toLowerCase() == name.toLowerCase(),
    );
    setState(() {
      if (existing >= 0) {
        _selected.add(_available[existing]);
      } else {
        _available.add(name);
        _selected.add(name);
      }
    });
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final result = EditProfileResult(
      bio: _bio.text.trim(),
      skills: [
        for (final s in _available)
          if (_selected.contains(s)) s,
      ],
    );
    if (widget.asOnboarding) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      return;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Scaffold(
      appBar: DsAppBar(
        title: 'Edit profile and skills',
        eyebrow: 'WORKSPACE',
        showBack: true,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                DsStagger(
                  spacing: AppSpacing.lg,
                  children: [
                    GithubConnectionCard(username: widget.data.githubUsername),
                    DsTextField(
                      label: 'Short bio',
                      controller: _bio,
                      maxLines: 4,
                      maxLength: _bioLimit,
                      keyboardType: TextInputType.multiline,
                      onChanged: (_) => setState(() {}),
                      helperText: '${_bio.text.length} / $_bioLimit',
                    ),
                    SkillsEditor(
                      available: _available,
                      selected: _selected,
                      onToggle: _toggle,
                      onAdd: _add,
                    ),
                    DsCard(
                      tone: DsCardTone.inset,
                      borderRadius: AppSpacing.radiusLg,
                      child: Row(
                        children: [
                          const DsIcon(
                            AppIcons.lock,
                            size: 20,
                            color: AppColors.teal,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'We only use public GitHub data and the skills '
                              'you add. You can delete them any time.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: ds.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.lg,
            ),
            child: DsButton(label: 'Save and see matches', onPressed: _save),
          ),
        ],
      ),
    );
  }
}
