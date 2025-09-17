import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_event.dart';
import '../bloc/alarm_state.dart';
import 'add_edit_alarm_screen.dart';

class AlarmDashboardScreen extends StatelessWidget {
  const AlarmDashboardScreen({Key? key}) : super(key: key);

  String _repeatInfo(alarm) {
    if (alarm.repeatDays.length == 7) {
      return 'Daily';
    } else if (alarm.customIntervalDays > 0) {
      return 'Every ${alarm.customIntervalDays} days';
    } else if (alarm.customIntervalHours > 0) {
      return 'Every ${alarm.customIntervalHours} hours';
    } else if (alarm.repeatDays.isNotEmpty) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return alarm.repeatDays.map((d) => days[d]).join(', ');
    }
    return 'Once';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Alarm Dashboard')),
      body: BlocBuilder<AlarmBloc, AlarmState>(
        builder: (context, state) {
          if (state is AlarmLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AlarmLoaded) {
            final alarms = state.alarms;
            if (alarms.isEmpty) {
              return const Center(child: Text('No alarms set.'));
            }
            alarms.sort((a, b) => a.time.compareTo(b.time));
            return ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return Dismissible(
                  key: Key(alarm.id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    context.read<AlarmBloc>().add(DeleteAlarm(alarm.id));
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Row(
                        children: [
                          Text(
                            '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (alarm.label.isNotEmpty)
                            Flexible(
                              child: Text(
                                alarm.label,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(_repeatInfo(alarm)),
                      trailing: Switch(
                        value: alarm.isActive,
                        onChanged: (val) {
                          context.read<AlarmBloc>().add(
                            ToggleAlarm(alarm.id, val),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEditAlarmScreen(alarm: alarm),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          } else if (state is AlarmError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditAlarmScreen()),
          );
        },
        child: const Icon(Icons.add_alarm),
      ),
    );
  }
}
