import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Global DevSync icons — [Lucide](https://lucide.dev) via `lucide_icons_flutter`.
///
/// Prefer [AppIcons] / [DsIcon] over raw [Icons] so the whole team stays consistent
/// with the HTML prototype icon set.
abstract final class AppIcons {
  // Navigation
  static const IconData back = LucideIcons.chevronLeft;
  static const IconData forward = LucideIcons.arrowRight;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData close = LucideIcons.x;
  static const IconData home = LucideIcons.house;

  // Auth
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;
  static const IconData google = LucideIcons.globe;
  static const IconData github = LucideIcons.gitBranch;
  static const IconData mail = LucideIcons.mail;
  static const IconData lock = LucideIcons.lockKeyhole;
  static const IconData shield = LucideIcons.shieldCheck;

  // Primary nav / features
  static const IconData feed = LucideIcons.sparkles;
  static const IconData projects = LucideIcons.folder;
  static const IconData requests = LucideIcons.handshake;
  static const IconData profile = LucideIcons.user;
  static const IconData tasks = LucideIcons.squareKanban;
  static const IconData notifications = LucideIcons.bell;
  static const IconData settings = LucideIcons.settings2;
  static const IconData designSystem = LucideIcons.palette;

  // Match / AI
  static const IconData sparkle = LucideIcons.sparkles;
  static const IconData code = LucideIcons.code;
  static const IconData heart = LucideIcons.heart;
  static const IconData undo = LucideIcons.undo2;

  // Feedback / status
  static const IconData info = LucideIcons.info;
  static const IconData warning = LucideIcons.triangleAlert;
  static const IconData error = LucideIcons.circleAlert;
  static const IconData success = LucideIcons.check;
  static const IconData inbox = LucideIcons.inbox;
  static const IconData construction = LucideIcons.construction;
  static const IconData search = LucideIcons.search;
  static const IconData plus = LucideIcons.plus;
  static const IconData edit = LucideIcons.pencil;
  static const IconData trash = LucideIcons.trash2;
  static const IconData share = LucideIcons.share2;
  static const IconData filter = LucideIcons.slidersHorizontal;
  static const IconData refresh = LucideIcons.refreshCw;
  static const IconData moon = LucideIcons.moon;
  static const IconData sun = LucideIcons.sun;
}
