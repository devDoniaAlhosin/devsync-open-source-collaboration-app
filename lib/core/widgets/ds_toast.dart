import 'dart:async';

import 'package:flutter/material.dart';

import '../icons/app_icons.dart';
import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'ds_icon.dart';

enum DsToastTone { error, success, info, warning }

OverlayEntry? _activeToastEntry;

/// Small top-right toast with tone color and smooth enter/exit.
void showDsToast(
  BuildContext context,
  String message, {
  DsToastTone tone = DsToastTone.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  _dismissActiveToast();

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _DsToastOverlay(
      message: message,
      tone: tone,
      icon: icon,
      duration: duration,
      onDismissed: () {
        if (_activeToastEntry == entry) {
          _activeToastEntry = null;
        }
        entry.remove();
      },
    ),
  );

  _activeToastEntry = entry;
  overlay.insert(entry);
}

void _dismissActiveToast() {
  final entry = _activeToastEntry;
  if (entry == null) return;
  _activeToastEntry = null;
  entry.remove();
}

class _DsToastOverlay extends StatefulWidget {
  const _DsToastOverlay({
    required this.message,
    required this.tone,
    required this.duration,
    required this.onDismissed,
    this.icon,
  });

  final String message;
  final DsToastTone tone;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_DsToastOverlay> createState() => _DsToastOverlayState();
}

class _DsToastOverlayState extends State<_DsToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
      reverseDuration: AppAnimations.fast,
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.emphasized,
      reverseCurve: AppAnimations.decelerate,
    );
    _fade = curve;
    _slide = Tween<Offset>(
      begin: const Offset(0.18, -0.12),
      end: Offset.zero,
    ).animate(curve);

    _controller.forward();
    _holdTimer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    _holdTimer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismissed();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = DevSyncPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final top = MediaQuery.paddingOf(context).top + 10;

    final Color accent;
    final IconData resolvedIcon;
    switch (widget.tone) {
      case DsToastTone.error:
        accent = palette.danger;
        resolvedIcon = widget.icon ?? AppIcons.error;
      case DsToastTone.success:
        accent = AppColors.teal;
        resolvedIcon = widget.icon ?? AppIcons.success;
      case DsToastTone.warning:
        accent = palette.danger;
        resolvedIcon = widget.icon ?? AppIcons.warning;
      case DsToastTone.info:
        accent = AppColors.teal;
        resolvedIcon = widget.icon ?? AppIcons.info;
    }

    return Positioned(
      top: top,
      right: 12,
      child: IgnorePointer(
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      accent.withValues(alpha: 0.12),
                      palette.surface,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.55),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: DsIcon(resolvedIcon, color: accent, size: 15),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
