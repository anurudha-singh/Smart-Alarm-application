import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alarm/alarm.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_event.dart';
import '../models/alarm_model.dart';

class AddEditAlarmScreen extends StatefulWidget {
  final AlarmModel? alarm;
  const AddEditAlarmScreen({Key? key, this.alarm}) : super(key: key);

  @override
  State<AddEditAlarmScreen> createState() => _AddEditAlarmScreenState();
}

class _AddEditAlarmScreenState extends State<AddEditAlarmScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  List<bool> _selectedDays = List.generate(7, (_) => false);
  String? _ringtonePath;
  int _customIntervalHours = 0;
  int _customIntervalDays = 0;

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _selectedTime = TimeOfDay(
        hour: widget.alarm!.time.hour,
        minute: widget.alarm!.time.minute,
      );
      _labelController = TextEditingController(text: widget.alarm!.label);
      for (var d in widget.alarm!.repeatDays) {
        _selectedDays[d] = true;
      }
      _ringtonePath = widget.alarm!.ringtonePath;
      _customIntervalHours = widget.alarm!.customIntervalHours;
      _customIntervalDays = widget.alarm!.customIntervalDays;
    } else {
      _selectedTime = TimeOfDay.now();
      _labelController = TextEditingController();
    }
  }

  Future<void> _pickRingtone() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _ringtonePath = result.files.single.path;
      });
    }
  }

  void _saveAlarm() async {
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final repeatDays = <int>[];
    for (int i = 0; i < 7; i++) {
      if (_selectedDays[i]) repeatDays.add(i);
    }
    final alarm = AlarmModel(
      id:
          widget.alarm?.id ??
          DateTime.now().millisecondsSinceEpoch % 2147483647,
      time: alarmTime,
      label: _labelController.text,
      repeatDays: repeatDays,
      isActive: true,
      ringtonePath: _ringtonePath ?? '',
      customIntervalHours: _customIntervalHours,
      customIntervalDays: _customIntervalDays,
    );
    if (widget.alarm == null) {
      context.read<AlarmBloc>().add(AddAlarm(alarm));
    } else {
      context.read<AlarmBloc>().add(UpdateAlarm(alarm));
      context.read<AlarmBloc>().add(LoadAlarms());
    }
    // Set alarm using alarm package
    final alarmSettings = AlarmSettings(
      id: alarm.id,
      dateTime: alarm.time,
      assetAudioPath: _ringtonePath?.isNotEmpty == true
          ? _ringtonePath!
          : 'assets/better-day.mp3', //Fallback to default if none selected
      loopAudio: _ringtonePath?.isNotEmpty == true,
      vibrate: true,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: Duration(seconds: 5),
        volumeEnforced: true,
      ),
      notificationSettings: const NotificationSettings(
        title: 'Alarm',
        body: 'Your alarm is ringing!',
        stopButton: 'Stop',
        icon: 'notification_icon',
        iconColor: Color(0xff862778),
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'Add Alarm' : 'Edit Alarm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Time: ${_selectedTime.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) {
                  setState(() => _selectedTime = picked);
                }
              },
            ),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: 16),
            Text('Repeat Days:'),
            ToggleButtons(
              children: const [
                Text('Mon'),
                Text('Tue'),
                Text('Wed'),
                Text('Thu'),
                Text('Fri'),
                Text('Sat'),
                Text('Sun'),
              ],
              isSelected: _selectedDays,
              onPressed: (int index) {
                setState(() => _selectedDays[index] = !_selectedDays[index]);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Every X hours',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        _customIntervalHours = int.tryParse(val) ?? 0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Every X days',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        _customIntervalDays = int.tryParse(val) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _ringtonePath == null ? 'Select Ringtone' : 'Ringtone Selected',
              ),
              trailing: Icon(Icons.music_note),
              onTap: _pickRingtone,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveAlarm,
              child: Text(widget.alarm == null ? 'Add Alarm' : 'Update Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}
