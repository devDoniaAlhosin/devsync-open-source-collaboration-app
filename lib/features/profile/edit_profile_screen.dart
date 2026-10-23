import 'package:devsync_open_source_collaboration_app/features/profile/widgets/githup_connection.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/widgets/skill_editor.dart';
import 'package:flutter/material.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_card.dart';
import '../../core/widgets/ds_icon.dart';
import '../../core/widgets/ds_icon_button.dart';
import '../../core/widgets/ds_text_field.dart';
import 'models/profile_data.dart';

class EditProfileResult {
  const EditProfileResult({required this.bio, required this.skills});

  final String bio;
  final List<String> skills;
}

/// Edit bio + toggle / add skills. Pops with an [EditProfileResult] on save.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.data});

  final ProfileData data;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const int _bioLimit = 140;

  late final TextEditingController _bio;
  late final List<String> _available; // keeps display order
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
        _selected.add(_available[existing]); // already there → just select it
      } else {
        _available.add(name);
        _selected.add(name);
      }
    });
  }

  void _save() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(
      EditProfileResult(
        bio: _bio.text.trim(),
        skills: [
          for (final s in _available)
            if (_selected.contains(s)) s,
        ],
      ),
    );
    // TODO: once the matches feed is built, route to AppRoutes.feed instead
    // ("Save and see matches").
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  DsIconButton(
                    icon: AppIcons.back,
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WORKSPACE',
                          style: textTheme.labelSmall?.copyWith(
                            color: ds.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 1.6,
                          ),
                        ),
                        Text(
                          'Edit profile and skills',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineSmall?.copyWith(
                            color: ds.textPrimary,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: ds.border),

            // ── Content ───────────────────────────────────────────
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                children: [
                  GithubConnectionCard(username: widget.data.githubUsername),
                  const SizedBox(height: AppSpacing.lg),
                  DsTextField(
                    label: 'Short bio',
                    controller: _bio,
                    maxLines: 4,
                    maxLength: _bioLimit,
                    keyboardType: TextInputType.multiline,
                    onChanged: (_) => setState(() {}),
                    helperText: '${_bio.text.length} / $_bioLimit',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SkillsEditor(
                    available: _available,
                    selected: _selected,
                    onToggle: _toggle,
                    onAdd: _add,
                  ),
                  const SizedBox(height: AppSpacing.xl),
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
            ),

            // ── Pinned action ─────────────────────────────────────
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
      ),
    );
  }
}
