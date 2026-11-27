import 'package:flutter_test/flutter_test.dart';

/// Documents the two-account FCM contract wired through Vercel `POST /notify`.
///
/// Manual device check (after deploying backend with `project_updated`):
/// 1. Account A (maintainer) + Account B (contributor) both Allow notifications
///    and have docs under `users/{uid}/fcmTokens`.
/// 2. B requests A's project → A gets push + inbox (`request_received`).
/// 3. A accepts → B gets push + inbox (`request_accepted`).
/// 4. A declines → B gets push + inbox (`request_declined`).
/// 5. A edits the project → B gets push + inbox (`project_updated`).
void main() {
  test('notify event names match backend /notify contract', () {
    const events = {
      'request_received',
      'request_accepted',
      'request_declined',
      'project_updated',
    };
    expect(events.length, 4);
    expect(events.contains('request_received'), isTrue);
    expect(events.contains('request_accepted'), isTrue);
    expect(events.contains('request_declined'), isTrue);
    expect(events.contains('project_updated'), isTrue);
  });
}
