import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_toast.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/data/datasources/github_token_store.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/github_scan_result.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/connect_github_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/entities/profile.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectGithubRouteArgs {
  const ConnectGithubRouteArgs({this.popOnSuccess = false});

  final bool popOnSuccess;

  static ConnectGithubRouteArgs from(Object? arguments) {
    if (arguments is ConnectGithubRouteArgs) return arguments;
    if (arguments is bool) return ConnectGithubRouteArgs(popOnSuccess: arguments);
    if (arguments is Map) {
      return ConnectGithubRouteArgs(
        popOnSuccess: arguments['popOnSuccess'] as bool? ?? false,
      );
    }
    return const ConnectGithubRouteArgs();
  }
}

class ConnectGithubEntry extends StatefulWidget {
  const ConnectGithubEntry({super.key, this.popOnSuccess = false});

  final bool popOnSuccess;

  factory ConnectGithubEntry.fromArgs(Object? arguments) {
    final args = ConnectGithubRouteArgs.from(arguments);
    return ConnectGithubEntry(popOnSuccess: args.popOnSuccess);
  }

  @override
  State<ConnectGithubEntry> createState() => _ConnectGithubEntryState();
}

class _ConnectGithubEntryState extends State<ConnectGithubEntry> {
  String _initialUsername = '';
  var _resolving = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final login = await _resolveGithubLogin();
    if (!mounted) return;
    setState(() {
      _initialUsername = login;
      _resolving = false;
    });
  }

  Future<String> _resolveGithubLogin() async {
    try {
      final fromStore = await getIt<GithubTokenStore>().readLogin();
      if (fromStore != null && fromStore.trim().isNotEmpty) {
        return fromStore.trim();
      }
    } catch (_) {
      // Fall through to Firestore.
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !getIt.isRegistered<UserRemoteDataSource>()) {
      return '';
    }
    try {
      return (await getIt<UserRemoteDataSource>().fetchGithubLogin(uid)) ?? '';
    } catch (_) {
      return '';
    }
  }

  void _onConnected(BuildContext context) {
    if (widget.popOnSuccess) {
      Navigator.of(context).pop(true);
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.editProfile);
  }

  @override
  Widget build(BuildContext context) {
    if (_resolving) {
      return Scaffold(
        backgroundColor: context.ds.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      create: (_) {
        final cubit = getIt<ProfileCubit>();
        if (_initialUsername.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cubit.scanGithub(_initialUsername);
          });
        }
        return cubit;
      },
      child: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            current is ProfileLoaded || current is ProfileFailure,
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _onConnected(context);
          } else if (state is ProfileFailure) {
            showDsToast(context, state.message, tone: DsToastTone.error);
          }
        },
        child: Builder(
          builder: (context) => ConnectGithubScreen(
            initialUsername: _initialUsername,
            onContinue: (result) => context.read<ProfileCubit>().saveGithubScan(
              githubUsername: result.username,
              repos: result.publicRepos,
              commits: result.commitsLastYear,
              languages: _toLanguageShares(result),
              bioSuggestion: result.bioSuggestion,
              activity: result.activity,
            ),
          ),
        ),
      ),
    );
  }
}

List<LanguageShare> _toLanguageShares(GithubScanResult result) {
  const palette = [0xFF2EE0C8, 0xFF8FBFB4, 0xFF3E5A57, 0xFF5BA8A0, 0xFF1F7A72];

  if (result.languages.isEmpty) return const [];

  return [
    for (var i = 0; i < result.languages.length && i < palette.length; i++)
      LanguageShare(
        name: result.languages[i],
        percent: result.languagePercents[result.languages[i]] ??
            _fallbackPercent(result, i),
        colorArgb: palette[i],
      ),
  ];
}

int _fallbackPercent(GithubScanResult result, int index) {
  const weights = [50, 25, 12, 8, 5];
  final names = result.languages.take(weights.length).toList();
  final total = weights.take(names.length).reduce((a, b) => a + b);
  final isLast = index == names.length - 1;
  if (isLast) {
    var used = 0;
    for (var i = 0; i < names.length - 1; i++) {
      used += (weights[i] * 100 / total).round();
    }
    return 100 - used;
  }
  return (weights[index] * 100 / total).round();
}
