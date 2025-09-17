import 'package:alarm/alarm.dart';

/// Builds a new AlarmSettings for a snoozed alarm.
///
/// - Preserves all properties from [current]
/// - Sets [dateTime] to [now] + [snoozeMinutes]
AlarmSettings buildSnoozedSettings({
  required AlarmSettings current,
  required int snoozeMinutes,
  required DateTime now,
}) {
  return current.copyWith(
    dateTime: now.add(Duration(minutes: snoozeMinutes)),
  );
}
