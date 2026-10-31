import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProjectFormField extends StatefulWidget {
  const ProjectFormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.validator,
    this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? suffixIcon;
  final TextCapitalization textCapitalization;

  @override
  State<ProjectFormField> createState() => _ProjectFormFieldState();
}

class _ProjectFormFieldState extends State<ProjectFormField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (value) => setState(() => _focused = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: context.ds.surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused
                ? AppColors.teal.withValues(alpha: 0.62)
                : context.ds.border,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.06),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style:
                  Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _focused ? AppColors.teal : context.ds.textMuted,
                    fontSize: 11.5,
                    letterSpacing: 0.1,
                  ) ??
                  const TextStyle(),
              child: Text(widget.label),
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    validator: widget.validator,
                    onChanged: widget.onChanged,
                    minLines: widget.minLines,
                    maxLines: widget.maxLines,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    textCapitalization: widget.textCapitalization,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15.5,
                      height: widget.maxLines > 1 ? 1.5 : 1.3,
                    ),
                    cursorColor: AppColors.teal,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: widget.hint,
                      hintStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            color: context.ds.textMuted.withValues(alpha: 0.62),
                            fontSize: 14.5,
                          ),
                      errorStyle: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: context.ds.danger, fontSize: 11.5),
                    ),
                  ),
                ),
                if (widget.suffixIcon != null) ...[
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      widget.suffixIcon,
                      size: 20,
                      color: context.ds.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
