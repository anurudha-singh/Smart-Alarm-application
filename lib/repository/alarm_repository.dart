import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/alarm_model.dart';

class AlarmRepository {
  static const String boxName = 'alarms';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AlarmModelAdapter());
    await Hive.openBox<AlarmModel>(boxName);
  }

  Box<AlarmModel> get _box => Hive.box<AlarmModel>(boxName);

  List<AlarmModel> getAlarms() {
    return _box.values.toList();
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    await _box.put(alarm.id, alarm);
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    // Ensure updates work even when a detached instance is provided
    await _box.put(alarm.id, alarm);
  }

  Future<void> deleteAlarm(int id) async {
    await _box.delete(id);
  }
}
