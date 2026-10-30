import 'dart:developer';

import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_animations.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_avatar.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_fade_switch.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/domain/entities/collaboration_request.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/screens/connected_celebration_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/requests/presentation/widgets/request_details.dart';
import 'package:flutter/material.dart';

class ExpandedRequestCard extends StatefulWidget {
  const ExpandedRequestCard({super.key, required this.item});
  final RequestItem item;

  @override
  State<ExpandedRequestCard> createState() => _ExpandedRequestCardState();
}

class _ExpandedRequestCardState extends State<ExpandedRequestCard> {
  late bool _expanded = widget.item.status == RequestStatus.isNew;
  RequestStatus? _statusOverride;

  RequestStatus get _status => _statusOverride ?? widget.item.status;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(context),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap:
                _status == RequestStatus.isNew &&
                    widget.item.type == RequestType.received
                ? _openDetails
                : _toggle,
            child: Row(
              children: [
                DsAvatar(initials: widget.item.initials, size: DsAvatarSize.sm),
                const SizedBox(width: 12),
                Expanded(child: _TitleBlock(widget.item)),
                _StatusBadge(_status),
                const SizedBox(width: 6),
                AnimatedRotation(
                  duration: AppAnimations.fast,
                  turns: _expanded ? 0.25 : 0,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: AppAnimations.fast,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _cardContent(colors)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _cardContent(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        if (widget.item.message != null &&
            _status != RequestStatus.declined &&
            _status != RequestStatus.accepted)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.item.message ?? 'empty message',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 12),

        if (_status == RequestStatus.pending)
          _ActionButton(
            label: 'View project',
            background: Colors.transparent,
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
            foreground: colors.onSurface,
            // onTap: () => Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (_) => RequestDetailsScreen(item: widget.item),
            //   ),
            // ),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Open project details')),
            ),
          )
        else if (_status == RequestStatus.isNew)
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _ActionButton(
                  label: 'Decline',
                  background: colors.surfaceContainerHighest,
                  foreground: colors.onSurfaceVariant,
                  onTap: () => log('Decline'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: _ActionButton(
                  label: 'Accept',
                  background: colors.primary,
                  foreground: colors.onPrimary,
                  onTap: () => _acceptAndCelebrate(context, widget.item),
                ),
              ),
            ],
          )
        else if (_status == RequestStatus.accepted)
          _ActionButton(
            label: 'Open task board',
            background: colors.primary,
            foreground: colors.onPrimary,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.tasks),
          )
        else if (_status == RequestStatus.declined)
          _ActionButton(
            label: 'No reply message. You can request other projects',
            background: Colors.transparent,
            foreground: colors.onSurfaceVariant,
            textStyle: TextStyle(
              // textAlign: TextAlign.start,
              fontSize: 12,
              // fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
            onTap: () {},
            // log('No reply message. You can request other projects'),
          ),
      ],
    );
  }

  Future<void> _openDetails() async {
    final status = await Navigator.of(context).push<RequestStatus>(
      DsFadePageRoute(
        builder: (_) => RequestDetailsScreen(item: widget.item),
      ),
    );
    if (!mounted || status == null) return;
    setState(() => _statusOverride = status);
    if (status == RequestStatus.accepted) {
      await _pushConnected(widget.item);
    }
  }

  Future<void> _acceptAndCelebrate(
    BuildContext context,
    RequestItem item,
  ) async {
    setState(() => _statusOverride = RequestStatus.accepted);
    await _pushConnected(item);
  }

  Future<void> _pushConnected(RequestItem item) {
    return Navigator.of(context).pushNamed(
      AppRoutes.connected,
      arguments: ConnectedCelebrationArgs(
        collaboratorName: item.displayName,
        collaboratorInitials: item.initials,
        projectName: item.targetName.isEmpty ? 'your project' : item.targetName,
      ),
    );
  }

}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.textStyle,
  });

  final String label;
  final Color background;
  final Color foreground;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style:
                  textStyle ??
                  TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock(this.item);
  final RequestItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.subtitle,
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);
  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    switch (status) {
      case RequestStatus.pending:
        return _pill(
          'Pending',
          colors.surfaceContainerHighest,
          colors.onSurfaceVariant,
        );
      case RequestStatus.isNew:
        return _pill('New', colors.primary, colors.onPrimary);
      case RequestStatus.accepted:
        return _pill('Accepted', colors.primary, colors.onPrimary);
      case RequestStatus.declined:
        return _pill(
          'Declined',
          colors.surfaceContainerHighest,
          colors.onSurfaceVariant,
        );
    }
  }

  Widget _pill(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
    ),
  );
}

BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
  color: Theme.of(context).colorScheme.surface,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: Theme.of(context).colorScheme.outline),
);
