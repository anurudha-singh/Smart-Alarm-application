import 'package:hive/hive.dart';

part 'alarm_model.g.dart';

@HiveType(typeId: 0)
class AlarmModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  DateTime time;

  @HiveField(2)
  String label;

  @HiveField(3)
  List<int> repeatDays; // 0=Mon, 6=Sun

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  String ringtonePath;

  @HiveField(6)
  int customIntervalHours;

  @HiveField(7)
  int customIntervalDays;

  AlarmModel({
    required this.id,
    required this.time,
    required this.label,
    required this.repeatDays,
    required this.isActive,
    required this.ringtonePath,
    required this.customIntervalHours,
    required this.customIntervalDays,
  });
}
