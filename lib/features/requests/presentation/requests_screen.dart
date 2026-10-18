import 'package:flutter/material.dart';
import '../domain/entities/collaboration_request.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  CollaborationRequestDirection _selectedDirection =
      CollaborationRequestDirection.incoming;

  late final List<CollaborationRequest> _requests = [
    ////// Dummy requests
    const CollaborationRequest(
      id: 'request-1',
      projectId: 'project-1',
      senderId: 'user-1',
      recipientId: 'current-user',
      message: 'I would love to contribute to your Flutter project.',
      status: CollaborationRequestStatus.pending,
      direction: CollaborationRequestDirection.incoming,
      projectName: 'DevSync Mobile App',
      senderName: 'Ahmed Mohamed',
    ),
    const CollaborationRequest(
      id: 'request-2',
      projectId: 'project-2',
      senderId: 'user-2',
      recipientId: 'current-user',
      message: 'I have experience with Firebase and would like to help.',
      status: CollaborationRequestStatus.pending,
      direction: CollaborationRequestDirection.incoming,
      projectName: 'Open Source Dashboard',
      senderName: 'Sara Ali',
    ),
    const CollaborationRequest(
      id: 'request-3',
      projectId: 'project-3',
      senderId: 'current-user',
      recipientId: 'user-3',
      message: 'I am interested in contributing to your project.',
      status: CollaborationRequestStatus.accepted,
      direction: CollaborationRequestDirection.outgoing,
      projectName: 'Flutter Starter Kit',
      recipientName: 'Omar Hassan',
    ),
    const CollaborationRequest(
      id: 'request-4',
      projectId: 'project-4',
      senderId: 'current-user',
      recipientId: 'user-4',
      message: 'Can I join your team?',
      status: CollaborationRequestStatus.pending,
      direction: CollaborationRequestDirection.outgoing,
      projectName: 'Developer Tools',
      recipientName: 'Mariam Adel',
    ),
  ];

  List<CollaborationRequest> get _visibleRequests {
    return _requests
        .where((request) => request.direction == _selectedDirection)
        .toList();
  }

  void _updateStatus(
    CollaborationRequest request,
    CollaborationRequestStatus status,
  ) {
    final index = _requests.indexWhere((item) => item.id == request.id);

    if (index == -1) return;

    setState(() {
      _requests[index] = CollaborationRequest(
        id: request.id,
        projectId: request.projectId,
        senderId: request.senderId,
        recipientId: request.recipientId,
        message: request.message,
        status: status,
        direction: request.direction,
        projectName: request.projectName,
        senderName: request.senderName,
        recipientName: request.recipientName,
        createdAt: request.createdAt,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == CollaborationRequestStatus.accepted
              ? 'Request accepted'
              : 'Request declined',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final requests = _visibleRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Collaboration Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Build something great together.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SegmentedButton<CollaborationRequestDirection>(
                segments: const [
                  ButtonSegment(
                    value: CollaborationRequestDirection.incoming,
                    label: Text('Received'),
                    icon: Icon(Icons.inbox_outlined),
                  ),
                  ButtonSegment(
                    value: CollaborationRequestDirection.outgoing,
                    label: Text('Sent'),
                    icon: Icon(Icons.send_outlined),
                  ),
                ],
                selected: {_selectedDirection},
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedDirection = selection.first;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    _selectedDirection == CollaborationRequestDirection.incoming
                        ? 'Received requests'
                        : 'Sent requests',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${requests.length} requests',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: requests.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: requests.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final request = requests[index];

                          return _RequestCard(
                            request: request,
                            onAccept: () => _updateStatus(
                              request,
                              CollaborationRequestStatus.accepted,
                            ),
                            onDecline: () => _updateStatus(
                              request,
                              CollaborationRequestStatus.declined,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final colors = theme.colorScheme;
    final isIncoming =
        _selectedDirection == CollaborationRequestDirection.incoming;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isIncoming ? Icons.inbox_outlined : Icons.send_outlined,
              size: 56,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              isIncoming ? 'No received requests' : 'No sent requests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New collaboration requests will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  final CollaborationRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isIncoming = request.isIncoming;
    final personName = isIncoming ? request.senderName : request.recipientName;

    final name = personName ?? 'Developer';

    final status = request.status;

    final statusLabel = switch (status) {
      CollaborationRequestStatus.pending => 'Pending',
      CollaborationRequestStatus.accepted => 'Accepted',
      CollaborationRequestStatus.declined => 'Declined',
    };

    final statusColor = switch (status) {
      CollaborationRequestStatus.pending => colors.tertiary,
      CollaborationRequestStatus.accepted => Colors.green,
      CollaborationRequestStatus.declined => colors.error,
    };

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isIncoming
                            ? 'Wants to collaborate'
                            : 'Collaboration request sent',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Project',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              request.projectName ?? 'Untitled project',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(request.message, style: theme.textTheme.bodyMedium),
            if (isIncoming && status == CollaborationRequestStatus.pending) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onAccept,
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
