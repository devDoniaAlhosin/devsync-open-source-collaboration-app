import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Named-route args for onboarding completion tab.
class EditProfileRouteArgs {
  const EditProfileRouteArgs({
    this.asOnboarding = true,
    this.homeTabIndex = 0,
  });

  final bool asOnboarding;
  final int homeTabIndex;

  static EditProfileRouteArgs from(Object? arguments) {
    if (arguments is EditProfileRouteArgs) return arguments;
    if (arguments is Map) {
      return EditProfileRouteArgs(
        asOnboarding: arguments['asOnboarding'] as bool? ?? true,
        homeTabIndex: arguments['homeTabIndex'] as int? ?? 0,
      );
    }
    return const EditProfileRouteArgs();
  }
}

class EditProfileEntry extends StatelessWidget {
  const EditProfileEntry({
    super.key,
    this.asOnboarding = true,
    this.homeTabIndex = 0,
  });

  final bool asOnboarding;
  final int homeTabIndex;

  factory EditProfileEntry.fromArgs(Object? arguments) {
    final args = EditProfileRouteArgs.from(arguments);
    return EditProfileEntry(
      asOnboarding: args.asOnboarding,
      homeTabIndex: args.homeTabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (prev, curr) =>
            curr is ProfileLoaded ||
            curr is ProfileLoading ||
            curr is ProfileInitial ||
            curr is ProfileFailure,
        builder: (context, state) {
          return switch (state) {
            ProfileLoaded(:final profile) => EditProfileScreen(
              data: profile,
              asOnboarding: asOnboarding,
              homeTabIndex: homeTabIndex,
            ),
            ProfileFailure(:final message) => Scaffold(
              backgroundColor: context.ds.background,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message),
                    TextButton(
                      onPressed: () => context.read<ProfileCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            _ => Scaffold(
              backgroundColor: context.ds.background,
              body: const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              ),
            ),
          };
        },
      ),
    );
  }
}
