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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Close RingingScreen if an alarm is stopped from notification/background
    Alarm.updateStream.stream.listen((_) {
      if (_isRingingScreenVisible) {
        navigatorKey.currentState?.maybePop();
        _isRingingScreenVisible = false;
      }
    });
    // Listen for alarm ringing and show RingingScreen
    Alarm.ringing.listen((settings) async {
      for (final alarm in settings.alarms) {
        // Try to fetch label from Hive using the same id
        String label = '';
        try {
          final box = Hive.box<AlarmModel>('alarms');
          final model = box.get(alarm.id);
          if (model != null) {
            label = model.label;
          }
        } catch (_) {}
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => RingingScreen(
              snoozeMinutes: 1, // TODO:: Remove post testing
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
                await Alarm.set(
                  alarmSettings: alarm.copyWith(
                    dateTime: DateTime.now().add(Duration(minutes: 1)),
                  ),
                );
              },
            ),
          ),
        );
        _isRingingScreenVisible = true;
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
