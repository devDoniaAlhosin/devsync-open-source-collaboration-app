import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../cubit/email_link_cubit.dart';

/// Listens for Firebase email-link URIs and completes passwordless sign-in.
class EmailLinkListener extends StatefulWidget {
  const EmailLinkListener({super.key, required this.child});

  final Widget child;

  @override
  State<EmailLinkListener> createState() => _EmailLinkListenerState();
}

class _EmailLinkListenerState extends State<EmailLinkListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  EmailLinkCubit? _cubit;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<EmailLinkCubit>()) {
      _cubit = getIt<EmailLinkCubit>();
    }
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _handle(initial);
      }
    } catch (_) {
      // Ignore cold-start link errors (e.g. tests without plugins).
    }

    _sub = _appLinks.uriLinkStream.listen(_handle, onError: (_) {});
  }

  Future<void> _handle(Uri uri) async {
    final cubit = _cubit;
    if (_handling || cubit == null) return;
    final link = uri.toString();
    if (!cubit.isSignInWithEmailLink(link)) return;

    _handling = true;
    try {
      await cubit.completeLink(link);
      if (!mounted) return;
      if (cubit.state is! EmailLinkCompleted) {
        if (cubit.state is EmailLinkFailure) {
          final message = (cubit.state as EmailLinkFailure).message;
          ScaffoldMessenger.maybeOf(
            context,
          )?.showSnackBar(SnackBar(content: Text(message)));
        }
        return;
      }

      Navigator.maybeOf(
        context,
      )?.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Signed in with email link')),
      );
    } finally {
      _handling = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _cubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
