import 'package:flutter/material.dart';
import 'package:devsync_open_source_collaboration_app/core/icons/app_icons.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_chip.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_icon.dart';

class SkillsEditor extends StatefulWidget {
  const SkillsEditor({
    super.key,
    required this.available,
    required this.selected,
    required this.onToggle,
    required this.onAdd,
  });

  final List<String> available;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onAdd;

  @override
  State<SkillsEditor> createState() => _SkillsEditorState();
}

class _SkillsEditorState extends State<SkillsEditor> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus && _adding) _submit();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startAdding() {
    setState(() => _adding = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) widget.onAdd(name);
    _controller.clear();
    if (_adding) setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills · tap to toggle',
          style: textTheme.labelMedium?.copyWith(
            color: ds.accentText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final skill in widget.available)
              DsChip(
                label: skill,
                selected: widget.selected.contains(skill),
                onTap: () => widget.onToggle(skill),
              ),

            if (_adding)
              SizedBox(
                width: 150,
                height: 36,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  maxLength: 24,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  cursorColor: AppColors.teal,
                  style: textTheme.bodySmall?.copyWith(
                    color: ds.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Skill',
                    hintStyle: textTheme.bodySmall?.copyWith(
                      color: ds.textMuted,
                      fontSize: 13,
                    ),
                    counterText: '',
                    isDense: true,
                    filled: true,
                    fillColor: ds.surfaceAlt,
                    contentPadding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      top: 10,
                      bottom: 10,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _submit,
                      tooltip: 'Add skill',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: const DsIcon(
                        AppIcons.success,
                        size: 16,
                        color: AppColors.teal,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(
                        color: AppColors.teal,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              )
            else
              TextButton.icon(
                onPressed: _startAdding,
                style: TextButton.styleFrom(
                  foregroundColor: ds.textMuted,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                icon: DsIcon(AppIcons.plus, size: 16, color: ds.textMuted),
                label: Text(
                  'Add',
                  style: textTheme.labelMedium?.copyWith(
                    color: ds.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
