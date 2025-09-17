import 'package:equatable/equatable.dart';
import '../models/alarm_model.dart';

abstract class AlarmEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAlarms extends AlarmEvent {}

class RefreshAlarms extends AlarmEvent {}

class AddAlarm extends AlarmEvent {
  final AlarmModel alarm;
  AddAlarm(this.alarm);
  @override
  List<Object?> get props => [alarm];
}

class UpdateAlarm extends AlarmEvent {
  final AlarmModel alarm;
  UpdateAlarm(this.alarm);
  @override
  List<Object?> get props => [alarm];
}

class DeleteAlarm extends AlarmEvent {
  final int id;
  DeleteAlarm(this.id);
  @override
  List<Object?> get props => [id];
}

class ToggleAlarm extends AlarmEvent {
  final int id;
  final bool isActive;
  ToggleAlarm(this.id, this.isActive);
  @override
  List<Object?> get props => [id, isActive];
}
