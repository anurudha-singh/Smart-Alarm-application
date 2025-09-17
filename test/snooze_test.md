How to test snooze manually:
- Set an alarm to ring soon.
- When the ringing UI appears, press Snooze.
- Expected:
  - Ringing screen closes immediately.
  - You will be redirected to the alarm Dashboard screen.
  - Alarm stops and a new alarm is scheduled for now + snoozeMinutes (currently 1 minute per your test setting).
  - After that duration, the alarm rings again.

To run tests:
- From project root:
  - flutter test test/alarm_utils_test.dart