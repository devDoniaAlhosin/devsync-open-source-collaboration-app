import 'package:flutter/material.dart';

/// Opens the nearest ancestor [Scaffold] that has a [Drawer].
///
/// Feature tabs nest their own [Scaffold]s inside [HomeShellScreen], so
/// [Scaffold.of] / [Scaffold.maybeOf] hit the inner scaffold (no drawer).
/// Walk up until a host with a drawer is found.
bool openHostDrawer(BuildContext context) {
  var scaffold = context.findAncestorStateOfType<ScaffoldState>();
  while (scaffold != null) {
    if (scaffold.hasDrawer) {
      scaffold.openDrawer();
      return true;
    }
    scaffold = scaffold.context.findAncestorStateOfType<ScaffoldState>();
  }
  return false;
}
