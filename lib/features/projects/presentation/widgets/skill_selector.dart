import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import 'tech_tag.dart';

class SkillSelector extends StatelessWidget {
  const SkillSelector({
    required this.availableSkills,
    required this.selectedSkills,
    required this.onToggle,
    required this.onAddSkill,
    this.errorText,
    super.key,
  });

  final List<String> availableSkills;
  final Set<String> selectedSkills;
  final ValueChanged<String> onToggle;
  final VoidCallback onAddSkill;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills needed',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: context.ds.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 11),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in availableSkills)
              TechTag(
                label: skill,
                selected: selectedSkills.contains(skill),
                showCheck: selectedSkills.contains(skill),
                onTap: () => onToggle(skill),
              ),
            _AddSkillChip(onTap: onAddSkill),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.topLeft,
          child: errorText == null
              ? const SizedBox(height: 8)
              : Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    errorText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.ds.danger,
                      fontSize: 11.5,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _AddSkillChip extends StatelessWidget {
  const _AddSkillChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: context.ds.textMuted.withValues(alpha: 0.38),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.plus, size: 14, color: context.ds.textMuted),
              const SizedBox(width: 5),
              Text(
                'Add',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.ds.textMuted,
                  fontSize: 12.5,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
