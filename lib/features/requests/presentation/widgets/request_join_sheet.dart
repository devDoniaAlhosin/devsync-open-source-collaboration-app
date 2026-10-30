import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_fade_switch.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../../core/widgets/ds_item_enter.dart';
import '../../domain/entities/collaboration_request.dart';

/// Result after the user confirms send on the join sheet success step.
class RequestJoinResult {
  const RequestJoinResult({
    required this.message,
    required this.maintainerName,
    required this.projectName,
  });

  final String message;
  final String maintainerName;
  final String projectName;
}

Future<RequestJoinResult?> showRequestJoinSheet(
  BuildContext context, {
  required RequestItem item,
  String maintainerName = 'Karim',
}) {
  return showModalBottomSheet<RequestJoinResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _RequestJoinSheet(
      item: item,
      maintainerName: maintainerName,
    ),
  );
}

class _RequestJoinSheet extends StatefulWidget {
  const _RequestJoinSheet({
    required this.item,
    required this.maintainerName,
  });

  final RequestItem item;
  final String maintainerName;

  @override
  State<_RequestJoinSheet> createState() => _RequestJoinSheetState();
}

class _RequestJoinSheetState extends State<_RequestJoinSheet> {
  late final TextEditingController _messageController;
  late final List<_RequestSuggestion> _suggestions;

  int? _selectedSuggestion = 0;
  bool _sent = false;
  String _sentMessage = '';

  @override
  void initState() {
    super.initState();
    final name = widget.maintainerName;
    _suggestions = [
      _RequestSuggestion(
        label: 'Offer animation',
        message:
            'Hi $name! I build Flutter animations and would love to help '
            'with chart transitions and tests.',
      ),
      _RequestSuggestion(
        label: 'Offer tests',
        message:
            'Hi $name! I would love to help test the charts and improve '
            'their reliability.',
      ),
      _RequestSuggestion(
        label: 'Ask for a task',
        message:
            'Hi $name! I would love to contribute. Is there a good first '
            'task I can take on?',
      ),
    ];
    _messageController = TextEditingController(
      text: _suggestions.first.message,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = DevSyncPalette.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
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
                AnimatedSwitcher(
                  duration: AppAnimations.itemEnter,
                  switchInCurve: AppAnimations.itemEnterCurve,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: dsFadeRiseSwitch,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        ?currentChild,
                      ],
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(_sent ? 'success' : 'form'),
                    child: _sent
                        ? _buildSuccess(context)
                        : _buildForm(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = DevSyncPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 42,
              child: Text(
                widget.item.initials,
                textAlign: TextAlign.center,
                style: textTheme.labelLarge?.copyWith(
                  color: palette.accentText,
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
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.maintainerName} sees your profile, score '
                    'and this note',
                    style: textTheme.bodySmall?.copyWith(
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
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your message',
                style: textTheme.labelSmall?.copyWith(
                  color: palette.accentText,
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
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
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
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DsButton(
          label: 'Send request',
          compact: true,
          onPressed: _messageController.text.trim().isEmpty
              ? null
              : _onSend,
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _SuccessCheckmark(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          DsItemEnter(
            index: 1,
            duration: AppAnimations.normal,
            child: Text(
              'Request sent',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DsItemEnter(
            index: 2,
            duration: AppAnimations.normal,
            child: Text(
              "We'll alert you the moment ${widget.maintainerName} replies.",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          DsItemEnter(
            index: 3,
            duration: AppAnimations.normal,
            child: DsButton(
              label: 'Done',
              onPressed: () {
                Navigator.of(context).pop(
                  RequestJoinResult(
                    message: _sentMessage,
                    maintainerName: widget.maintainerName,
                    projectName: widget.item.title,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSend() {
    setState(() {
      _sentMessage = _messageController.text.trim();
      _sent = true;
    });
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

/// Teal check that pops in like prototype `pop2` + delayed icon (`dr2`).
class _SuccessCheckmark extends StatefulWidget {
  @override
  State<_SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<_SuccessCheckmark>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 600);

  late final AnimationController _controller;
  late final Animation<double> _circleFade;
  late final Animation<double> _circleScale;
  late final Animation<double> _iconFade;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);

    final circle = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.emphasized,
    );
    _circleFade = circle;
    _circleScale = Tween<double>(begin: 0.3, end: 1).animate(circle);

    // Prototype stroke draw starts at ~300ms of the 600ms pop.
    final icon = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1, curve: AppAnimations.emphasized),
    );
    _iconFade = icon;
    _iconScale = Tween<double>(begin: 0.6, end: 1).animate(icon);

    if (WidgetsBinding.instance.disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return _buildCircle(iconOpacity: 1, iconScale: 1);
    }
    return FadeTransition(
      opacity: _circleFade,
      child: ScaleTransition(
        scale: _circleScale,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return _buildCircle(
              iconOpacity: _iconFade.value,
              iconScale: _iconScale.value,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCircle({
    required double iconOpacity,
    required double iconScale,
  }) {
    return SizedBox(
      width: 72,
      height: 72,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.teal,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Opacity(
            opacity: iconOpacity,
            child: Transform.scale(
              scale: iconScale,
              child: const DsIcon(
                AppIcons.success,
                size: 32,
                color: AppColors.onTeal,
              ),
            ),
          ),
        ),
      ),
    );
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
