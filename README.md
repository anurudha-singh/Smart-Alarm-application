# Smart Alarm App

A production-ready Flutter alarm app with Hive persistence, BLoC state management, polished UI, and reliable alarm scheduling via the `alarm` package.

## Features

- Alarm CRUD with Hive (`AlarmModel`)
- Custom repeat: weekly days, every X hours, every Y days
- Custom ringtone (file picker) with default asset fallback
- Full-screen ringing UI with Stop/Snooze
- Snooze configurable (currently 5 minutes)
- Notification Stop integration (auto-close ringing screen)
- Dashboard with search, filter, sort, and next-occurrence chips
- Adaptive loading indicators and improved empty states

## Recent Improvements

- Ringing screen now displays the alarm label
- Fix: If Stop pressed from notification, avoid re-showing the ringing UI
- UI auto-refresh after add/update/delete/toggle via BLoC
- Repository update fixed to persist detached instances with `box.put`
- Snooze utility `buildSnoozedSettings` with unit test
- Dashboard redesign: professional cards, chips, AppBar actions
- Platform adaptive progress indicator
- Searchable AppBar, filter (All/Active/Inactive), sort (Time/Label)
- Toggle behavior for expired once-alarms: allow enable; block disable
- Next occurrence logic fixed to update only the affected card

## Architecture

- State: BLoC (`AlarmBloc`, `AlarmEvent`, `AlarmState`)
- Storage: Hive (`AlarmModel`, `alarm_model.g.dart`)
- Scheduling: `alarm` package, `AlarmSettings`, `Alarm.ringing`, `Alarm.updateStream`
- DI: simple service locator (`service_locator.dart`)

## Key Files

- `lib/main.dart`
  - App bootstrap, Hive init, alarm listeners
  - Unified `snoozeMinutes = 5` used for UI and scheduling
- `lib/models/alarm_model.dart`
  - Hive model: id, time, label, repeatDays, isActive, ringtonePath, customIntervalHours/Days
- `lib/repository/alarm_repository.dart`
  - Uses `box.put(id, alarm)` for reliable updates
- `lib/bloc/*`
  - Toggle logic rolls past once-alarms to next day when re-enabled
  - `RefreshAlarms` emits `AlarmLoading` for visible refresh feedback
- `lib/screens/ringing_screen.dart`
  - Shows label, Stop and Snooze buttons
- `lib/screens/alarm_dashboard_screen.dart`
  - Search/Filter/Sort AppBar, chips (repeat/expired/next-in), disabled toggle with border
  - Accurate next-occurrence for once alarms (uses stored `alarm.time`)
- `lib/utils/alarm_utils.dart`
  - `buildSnoozedSettings` helper
- `test/alarm_utils_test.dart`
  - Verifies snooze math (now + X minutes)

## Snooze Logic

- Utility: `buildSnoozedSettings(current, snoozeMinutes, now)` returns `current.copyWith(dateTime: now + snoozeMinutes)`
- App uses a single constant `snoozeMinutes = 5`

## UX Details

- Expired once-alarms show an "Expired" chip
- Their toggles: enabling allowed (reschedules to next day), disabling blocked
- When alarm is stopped from the system notification, the ringing UI is popped

## Run

1. flutter pub get
2. flutter run

For tests:

```bash
flutter test test/alarm_utils_test.dart
```

## Notes

- Android uses full-screen intent for alarms
- Ensure notification permissions are granted

## License

MIT
