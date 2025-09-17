// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_model.dart';

class AlarmModelAdapter extends TypeAdapter<AlarmModel> {
  @override
  final int typeId = 0;

  @override
  AlarmModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlarmModel(
      id: fields[0] as int,
      time: fields[1] as DateTime,
      label: fields[2] as String,
      repeatDays: (fields[3] as List).cast<int>(),
      isActive: fields[4] as bool,
      ringtonePath: fields[5] as String,
      customIntervalHours: fields[6] as int,
      customIntervalDays: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AlarmModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.repeatDays)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.ringtonePath)
      ..writeByte(6)
      ..write(obj.customIntervalHours)
      ..writeByte(7)
      ..write(obj.customIntervalDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
