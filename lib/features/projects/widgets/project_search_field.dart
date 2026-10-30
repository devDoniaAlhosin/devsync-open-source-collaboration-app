import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';

class ProjectSearchField extends StatelessWidget {
  const ProjectSearchField({
    required this.controller,
    required this.onChanged,
    this.hint = 'Explore open-source projects',
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: context.ds.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.ds.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(AppIcons.search, size: 21, color: context.ds.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.ds.textMuted,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox(width: 14);
              }
              return IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: Icon(
                  AppIcons.close,
                  size: 18,
                  color: context.ds.textMuted,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
