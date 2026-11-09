import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileEntry extends StatelessWidget {
  const EditProfileEntry({super.key, this.asOnboarding = true});

  final bool asOnboarding;

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
            ),
            ProfileFailure(:final message) => Scaffold(
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
            _ => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              ),
            ),
          };
        },
      ),
    );
  }
}
