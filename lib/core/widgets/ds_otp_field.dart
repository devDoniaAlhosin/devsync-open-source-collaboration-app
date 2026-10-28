import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Six-box one-time code input (prototype `.auth-code`).
class DsOtpField extends StatefulWidget {
  const DsOtpField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  State<DsOtpField> createState() => _DsOtpFieldState();
}

class _DsOtpFieldState extends State<DsOtpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      final chars = value.replaceAll(RegExp(r'\D'), '').split('');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < chars.length ? chars[i] : '';
      }
      final focusIndex = chars.length.clamp(0, widget.length - 1);
      _nodes[focusIndex].requestFocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }

    final code = _code;
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Row(
      children: List.generate(widget.length, (i) {
        final filled = _controllers[i].text.isNotEmpty;
        final focused = _nodes[i].hasFocus;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 7),
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ds.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: filled || focused ? AppColors.teal : ds.border,
                width: filled || focused ? 2 : 1.5,
              ),
              boxShadow: focused
                  ? [const BoxShadow(color: AppColors.glow, blurRadius: 12)]
                  : null,
            ),
            child: TextField(
              controller: _controllers[i],
              focusNode: _nodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: ds.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
              onChanged: (v) => _onChanged(i, v),
              onTap: () => setState(() {}),
            ),
          ),
        );
      }),
    );
  }
}
