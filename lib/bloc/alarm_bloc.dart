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
      await repository.updateAlarm(alarm);
      add(LoadAlarms());
    });
  }
}
