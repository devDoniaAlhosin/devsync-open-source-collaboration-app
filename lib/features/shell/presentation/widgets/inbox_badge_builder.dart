import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../cubit/inbox_badges_cubit.dart';

/// Rebuilds when unread / pending-request badge flags change.
class InboxBadgeBuilder extends StatelessWidget {
  const InboxBadgeBuilder({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    bool hasUnreadNotifications,
    bool hasNewRequests,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    if (!getIt.isRegistered<InboxBadgesCubit>()) {
      return builder(context, false, false);
    }

    return BlocProvider.value(
      value: getIt<InboxBadgesCubit>(),
      child: BlocBuilder<InboxBadgesCubit, InboxBadgesState>(
        buildWhen: (previous, current) =>
            previous.hasUnreadNotifications != current.hasUnreadNotifications ||
            previous.hasNewRequests != current.hasNewRequests,
        builder: (context, state) => builder(
          context,
          state.hasUnreadNotifications,
          state.hasNewRequests,
        ),
      ),
    );
  }
}
