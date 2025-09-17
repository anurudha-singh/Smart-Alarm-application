import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/alarm_model.dart';
import 'repository/alarm_repository.dart';
import 'bloc/alarm_bloc.dart';
import 'bloc/alarm_event.dart';
import 'screens/alarm_dashboard_screen.dart';
import 'screens/ringing_screen.dart';
import 'service_locator.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AlarmModelAdapter());
  await Hive.openBox<AlarmModel>('alarms');
  await Alarm.init();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for alarm ringing and show RingingScreen
    Alarm.ringing.listen((settings) {
      for (final alarm in settings.alarms) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => RingingScreen(
              onStop: () async {
                await Alarm.stop(alarm.id);
                navigatorKey.currentState?.pop();
              },
              onSnooze: () async {
                await Alarm.stop(alarm.id);
                await Alarm.set(
                  alarmSettings: alarm.copyWith(
                    dateTime: DateTime.now().add(Duration(minutes: 1)),
                  ),
                );
                navigatorKey.currentState?.pop();
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
        home: const AlarmDashboardScreen(),
      ),
    );
  }
}
