import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/github_scan_result.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/connect_github_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/entities/profile.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectGithubEntry extends StatelessWidget {
  const ConnectGithubEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>(),
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.editProfile);
          } else if (state is ProfileFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Builder(
          builder: (context) => ConnectGithubScreen(
            onContinue: (result) => context.read<ProfileCubit>().saveGithubScan(
              githubUsername: result.username,
              repos: result.publicRepos,
              commits: result.commitsLastYear,
              languages: _toLanguageShares(result),
            ),
          ),
        ),
      ),
    );
  }
}

List<LanguageShare> _toLanguageShares(GithubScanResult result) {
  const palette = [0xFF2EE0C8, 0xFF8FBFB4, 0xFF3E5A57, 0xFF5BA8A0, 0xFF1F7A72];
  const weights = [50, 25, 12, 8, 5];

  final names = result.languages.take(weights.length).toList();
  if (names.isEmpty) return const [];

  final total = weights.take(names.length).reduce((a, b) => a + b);
  var used = 0;
  return [
    for (var i = 0; i < names.length; i++)
      () {
        final isLast = i == names.length - 1;
        final percent = isLast
            ? 100 - used
            : (weights[i] * 100 / total).round();
        used += percent;
        return LanguageShare(
          name: names[i],
          percent: percent,
          colorArgb: palette[i],
        );
      }(),
  ];
}
