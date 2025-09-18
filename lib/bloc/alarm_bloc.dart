import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/alarm_repository.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmRepository repository;

  AlarmBloc(this.repository) : super(AlarmInitial()) {
    on<LoadAlarms>((event, emit) async {
      emit(AlarmLoading());
      try {
        final alarms = repository.getAlarms();
        emit(AlarmLoaded(alarms));
      } catch (e) {
        emit(AlarmError(e.toString()));
      }
    });

    on<RefreshAlarms>((event, emit) async {
      emit(AlarmLoading());
      try {
        final alarms = repository.getAlarms();
        // Simulate a short async fetch to ensure spinner shows briefly
        await Future<void>.delayed(const Duration(milliseconds: 250));
        emit(AlarmLoaded(alarms));
      } catch (e) {
        emit(AlarmError(e.toString()));
      }
    });

    on<SyncAlarmState>((event, emit) async {
      try {
        final alarms = repository.getAlarms();
        final alarm = alarms.firstWhere((a) => a.id == event.alarmId);
        alarm.isActive = event.isActive;
        await repository.updateAlarm(alarm);
        add(LoadAlarms());
      } catch (e) {
        emit(AlarmError(e.toString()));
      }
    });

    on<AddAlarm>((event, emit) async {
      await repository.addAlarm(event.alarm);
      add(LoadAlarms());
    });

    on<UpdateAlarm>((event, emit) async {
      await repository.updateAlarm(event.alarm);
      add(LoadAlarms());
    });

    on<DeleteAlarm>((event, emit) async {
      await repository.deleteAlarm(event.id);
      add(LoadAlarms());
    });

    on<ToggleAlarm>((event, emit) async {
      final alarms = repository.getAlarms();
      final alarm = alarms.firstWhere((a) => a.id == event.id);
      alarm.isActive = event.isActive;
      // UX improvement: If re-enabling a 'Once' alarm and its time is in the past, set to next day
      if (event.isActive &&
          alarm.repeatDays.isEmpty &&
          alarm.customIntervalDays == 0 &&
          alarm.customIntervalHours == 0 &&
          alarm.time.isBefore(DateTime.now())) {
        alarm.time = DateTime.now().add(Duration(days: 1)).copyWith(
              hour: alarm.time.hour,
              minute: alarm.time.minute,
              second: 0,
              millisecond: 0,
              microsecond: 0,
            );
      }
      await repository.updateAlarm(alarm);
      add(LoadAlarms());
    });
  }
}
