import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import 'auth_service.dart';

/// Listens for Firebase email-link URIs and completes passwordless sign-in.
class EmailLinkListener extends StatefulWidget {
  const EmailLinkListener({super.key, required this.child});

  final Widget child;

  @override
  State<EmailLinkListener> createState() => _EmailLinkListenerState();
}

class _EmailLinkListenerState extends State<EmailLinkListener> {
  final _auth = AuthService();
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
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

    _sub = _appLinks.uriLinkStream.listen(
      _handle,
      onError: (_) {},
    );
  }

  Future<void> _handle(Uri uri) async {
    if (_handling) return;
    final link = uri.toString();
    if (!_auth.isSignInWithEmailLink(link)) return;

    _handling = true;
    try {
      final credential = await _auth.completeSignInWithEmailLink(link);
      if (!mounted || credential == null) return;

      final nav = Navigator.maybeOf(context);
      nav?.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);

      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Signed in with email link')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(AuthService.messageFor(e))),
      );
    } finally {
      _handling = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
