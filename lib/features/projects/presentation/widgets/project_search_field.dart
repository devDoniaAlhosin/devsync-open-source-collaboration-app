import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';

class ProjectSearchField extends StatefulWidget {
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
  State<ProjectSearchField> createState() => _ProjectSearchFieldState();
}

class _ProjectSearchFieldState extends State<ProjectSearchField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 54,
      decoration: BoxDecoration(
        color: context.ds.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused
              ? AppColors.teal.withValues(alpha: 0.72)
              : context.ds.border,
          width: focused ? 1.5 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            AppIcons.search,
            size: 21,
            color: focused ? AppColors.teal : context.ds.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 15),
              decoration: InputDecoration(
                hintText: widget.hint,
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
            valueListenable: widget.controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox(width: 14);
              }
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  tooltip: 'Clear search',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged('');
                    _focusNode.requestFocus();
                  },
                  icon: Icon(
                    AppIcons.close,
                    size: 18,
                    color: context.ds.textMuted,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
