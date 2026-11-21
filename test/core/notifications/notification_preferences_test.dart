import 'package:devsync_open_source_collaboration_app/core/notifications/notification_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('request types are gated by requests flag', () {
    const off = NotificationPreferences(requests: false, matches: true);
    expect(off.allowsType('request_received'), isFalse);
    expect(off.allowsType('request_accepted'), isFalse);
    expect(off.allowsType('project_updated'), isFalse);
    expect(off.allowsType('new_match'), isTrue);
  });

  test('match types are gated by matches flag', () {
    const off = NotificationPreferences(requests: true, matches: false);
    expect(off.allowsType('new_match'), isFalse);
    expect(off.allowsType('match_ready'), isFalse);
    expect(off.allowsType('request_received'), isTrue);
  });

  test('defaults allow all known types', () {
    const defaults = NotificationPreferences();
    expect(defaults.allowsType('request_received'), isTrue);
    expect(defaults.allowsType('new_match'), isTrue);
  });
}
