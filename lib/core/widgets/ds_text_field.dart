import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'ds_icon.dart';

/// Floating-label field (prototype `.fi`).
class DsTextField extends StatelessWidget {
  const DsTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.helperText,
    this.maxLines = 1,
    this.maxLength,
    this.suffix,
    this.enabled = true,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final String? helperText;
  final int maxLines;
  final int? maxLength;
  final Widget? suffix;
  final bool enabled;
  final Iterable<String>? autofillHints;

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = DevSyncPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          enabled: enabled,
          autofillHints: autofillHints,
          style: textTheme.bodyLarge,
          cursorColor: AppColors.teal,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: textTheme.bodyMedium?.copyWith(
              color: palette.textMuted,
            ),
            floatingLabelStyle: textTheme.labelMedium?.copyWith(
              color: palette.accentText,
            ),
            filled: true,
            fillColor: palette.surface,
            counterText: '',
            contentPadding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              maxLines > 1 ? AppSpacing.xxl : 22,
              suffix != null ? 48 : AppSpacing.lg,
              maxLines > 1 ? AppSpacing.lg : 10,
            ),
            suffixIcon: suffix,
            border: _border(palette.border, 1.5),
            enabledBorder: _border(
              _hasError ? palette.danger : palette.border,
              _hasError ? 2 : 1.5,
            ),
            focusedBorder: _border(
              _hasError ? palette.danger : AppColors.teal,
              2,
            ),
            errorBorder: _border(palette.danger, 2),
            focusedErrorBorder: _border(palette.danger, 2),
            disabledBorder: _border(palette.border, 1.5),
          ),
        ),
        if (_hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              DsIcon(AppIcons.error, size: 16, color: palette.danger),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  errorText!,
                  style: textTheme.bodySmall?.copyWith(color: palette.danger),
                ),
              ),
            ],
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: textTheme.bodySmall,
            textAlign: TextAlign.right,
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
