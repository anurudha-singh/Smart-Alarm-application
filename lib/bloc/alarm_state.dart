import 'package:equatable/equatable.dart';
import '../models/alarm_model.dart';

abstract class AlarmState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AlarmInitial extends AlarmState {}

class AlarmLoading extends AlarmState {}

class AlarmLoaded extends AlarmState {
  final List<AlarmModel> alarms;
  AlarmLoaded(this.alarms);
  @override
  List<Object?> get props => [alarms];
}

class AlarmError extends AlarmState {
  final String message;
  AlarmError(this.message);
  @override
  List<Object?> get props => [message];
}
