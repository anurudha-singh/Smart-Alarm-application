import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/alarm_model.dart';
import 'repository/alarm_repository.dart';
import 'bloc/alarm_bloc.dart';
import 'bloc/alarm_event.dart';
import 'screens/ringing_screen.dart';
import 'screens/splash_screen.dart';
import 'service_locator.dart';
import 'utils/alarm_utils.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool _isRingingScreenVisible = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AlarmModelAdapter());
  await Hive.openBox<AlarmModel>('alarms');
  await Alarm.init();
  await Permission.notification.request();
  setupLocator();

  // Reset ringing screen visibility on app startup
  _isRingingScreenVisible = false;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const int snoozeMinutes = 5; // unified snooze duration
    // Close RingingScreen if an alarm is stopped from notification/background
    Alarm.updateStream.stream.listen((update) {
      // Check if any alarm was stopped (not just updated)
      if (_isRingingScreenVisible) {
        // Pop the ringing screen when any alarm update occurs
        // This covers both stop and snooze actions from notifications
        navigatorKey.currentState?.maybePop();
        _isRingingScreenVisible = false;
      }
    });
    // Listen for alarm ringing and show RingingScreen
    Alarm.ringing.listen((settings) async {
      for (final alarm in settings.alarms) {
        // Check if ringing screen is already visible to avoid duplicates
        if (_isRingingScreenVisible) return;

        // Add a small delay to allow the system to process any stop operations
        await Future.delayed(const Duration(milliseconds: 200));

        // Double-check if alarm is still active after the delay
        try {
          final box = Hive.box<AlarmModel>('alarms');
          final model = box.get(alarm.id);
          if (model == null || !model.isActive) {
            // Alarm was stopped or doesn't exist, don't show ringing screen
            return;
          }

          // Additional check: verify the alarm time hasn't passed too long ago
          // If the alarm was supposed to ring more than 1 minute ago, it's likely been stopped
          final timeSinceAlarm = DateTime.now().difference(alarm.dateTime);
          if (timeSinceAlarm.inMinutes > 1) {
            // Alarm is too old, likely been stopped, don't show ringing screen
            return;
          }
        } catch (_) {
          // If we can't check the alarm state, don't show ringing screen
          return;
        }

        // Try to fetch label from Hive using the same id
        String label = '';
        try {
          final box = Hive.box<AlarmModel>('alarms');
          final model = box.get(alarm.id);
          if (model != null) {
            label = model.label;
          }
        } catch (_) {}

        _isRingingScreenVisible = true;
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => RingingScreen(
              snoozeMinutes: snoozeMinutes,
              label: label,
              onStop: () async {
                navigatorKey.currentState?.pop();
                _isRingingScreenVisible = false;
                await Alarm.stop(alarm.id);
                // Auto-disable "Once" alarms after ringing
                final box = Hive.box<AlarmModel>('alarms');
                final alarmModel = box.get(alarm.id);
                if (alarmModel != null &&
                    (alarmModel.repeatDays.isEmpty &&
                        (alarmModel.customIntervalDays == 0 &&
                            alarmModel.customIntervalHours == 0))) {
                  alarmModel.isActive = false;
                  await alarmModel.save();
                  // Dispatch BLoC events to update UI
                  navigatorKey.currentState?.context.read<AlarmBloc>().add(
                        UpdateAlarm(alarmModel),
                      );
                  navigatorKey.currentState?.context.read<AlarmBloc>().add(
                        LoadAlarms(),
                      );
                }
              },
              onSnooze: () async {
                navigatorKey.currentState?.pop();
                _isRingingScreenVisible = false;
                await Alarm.stop(alarm.id);
                final snoozed = buildSnoozedSettings(
                  current: alarm,
                  snoozeMinutes: snoozeMinutes,
                  now: DateTime.now(),
                );
                await Alarm.set(alarmSettings: snoozed);
              },
            ),
          ),
        );
      }
    });
    return BlocProvider(
      create: (_) => AlarmBloc(sl<AlarmRepository>())..add(LoadAlarms()),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Smart Alarm',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashOrHome(),
      ),
    );
  }
}
