import 'package:alarm/alarm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_alarm_app/utils/alarm_utils.dart';

void main() {
  group('buildSnoozedSettings', () {
    test('returns settings with dateTime = now + snoozeMinutes', () {
      final now = DateTime(2025, 1, 1, 8, 30);
      final current = AlarmSettings(
        id: 1,
        dateTime: DateTime(2025, 1, 1, 8, 0),
        assetAudioPath: 'assets/better-day.mp3',
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: true,
        androidFullScreenIntent: true,
        volumeSettings: VolumeSettings.fade(
          volume: 0.8,
          fadeDuration: const Duration(seconds: 5),
          volumeEnforced: true,
        ),
        notificationSettings: const NotificationSettings(
          title: 'Alarm',
          body: 'Your alarm is ringing!',
          stopButton: 'Stop',
          icon: 'notification_icon',
        ),
      );

      final snoozed = buildSnoozedSettings(
        current: current,
        snoozeMinutes: 7,
        now: now,
      );

      expect(snoozed.id, current.id);
      expect(snoozed.assetAudioPath, current.assetAudioPath);
      expect(snoozed.dateTime, now.add(const Duration(minutes: 7)));
    });
  });
}
