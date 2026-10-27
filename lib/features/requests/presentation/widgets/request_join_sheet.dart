import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/entities/collaboration_request.dart';
import 'package:flutter/material.dart';

const _initialRequestMessage =
    'Hi Karim! I build Flutter animations and would love to help with chart transitions and tests.';

Future<String?> showRequestJoinSheet(BuildContext context, RequestItem item) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _RequestJoinSheet(item: item),
  );
}

class _RequestJoinSheet extends StatefulWidget {
  const _RequestJoinSheet({required this.item});

  final RequestItem item;

  @override
  State<_RequestJoinSheet> createState() => _RequestJoinSheetState();
}

class _RequestJoinSheetState extends State<_RequestJoinSheet> {
  late final TextEditingController _messageController = TextEditingController(
    text: _initialRequestMessage,
  );

  static const _suggestions = <_RequestSuggestion>[
    _RequestSuggestion(
      label: 'Offer animation',
      message: _initialRequestMessage,
    ),
    _RequestSuggestion(
      label: 'Offer tests',
      message:
          'Hi Karim! I would love to help test the charts and improve their reliability.',
    ),
    _RequestSuggestion(
      label: 'Ask for a task',
      message:
          'Hi Karim! I would love to contribute. Is there a good first task I can take on?',
    ),
  ];

  int? _selectedSuggestion = 0;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = DevSyncPalette.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: Text(
                        widget.item.initials,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.accentText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ask to join',
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Karim sees your profile, score and this note',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 6,
                  runSpacing: 8,
                  children: [
                    for (var index = 0; index < _suggestions.length; index++)
                      _SuggestionChip(
                        suggestion: _suggestions[index],
                        selected: _selectedSuggestion == index,
                        onTap: () => _selectSuggestion(index),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  decoration: BoxDecoration(
                    color: colors.brightness == Brightness.light
                        ? Colors.white
                        : colors.surfaceContainerHighest,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your message',
                        style: TextStyle(
                          color: palette.accentText,
                          fontSize: 10,
                        ),
                      ),
                      TextField(
                        controller: _messageController,
                        maxLength: 280,
                        maxLines: 3,
                        minLines: 3,
                        onChanged: (_) {
                          setState(() => _selectedSuggestion = null);
                        },
                        decoration: const InputDecoration(
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
                        ),
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, right: 2),
                    child: Text(
                      '${_messageController.text.length}/280',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: FilledButton(
                    onPressed: _messageController.text.trim().isEmpty
                        ? null
                        : () => Navigator.of(
                            context,
                          ).pop(_messageController.text.trim()),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: AppColors.onTeal,
                      disabledBackgroundColor: colors.surfaceContainerHighest,
                      disabledForegroundColor: colors.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Send request',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectSuggestion(int index) {
    setState(() {
      _selectedSuggestion = index;
      _messageController.text = _suggestions[index].message;
      _messageController.selection = TextSelection.collapsed(
        offset: _messageController.text.length,
      );
    });
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.suggestion,
    required this.selected,
    required this.onTap,
  });

  final _RequestSuggestion suggestion;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Text(
            suggestion.label,
            style: TextStyle(
              color: selected ? colors.onSurface : colors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestSuggestion {
  const _RequestSuggestion({required this.label, required this.message});

  final String label;
  final String message;
}
