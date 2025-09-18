import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_event.dart';
import '../bloc/alarm_state.dart';
import 'add_edit_alarm_screen.dart';

class AlarmDashboardScreen extends StatefulWidget {
  const AlarmDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AlarmDashboardScreen> createState() => _AlarmDashboardScreenState();
}

enum _AlarmFilter { all, active, inactive }

enum _AlarmSort { timeAsc, timeDesc, labelAsc }

class _AlarmDashboardScreenState extends State<AlarmDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  _AlarmFilter _filter = _AlarmFilter.all;
  _AlarmSort _sort = _AlarmSort.timeAsc;

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

  DateTime _nextOccurrence(alarm) {
    final now = DateTime.now();
    // For once alarms, use the actual scheduled time directly so only that card updates
    if (alarm.repeatDays.isEmpty &&
        alarm.customIntervalDays == 0 &&
        alarm.customIntervalHours == 0) {
      return alarm.time;
    }
    DateTime base = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    // Custom hourly interval
    if (alarm.customIntervalHours > 0) {
      DateTime t = base;
      while (!t.isAfter(now)) {
        t = t.add(Duration(hours: alarm.customIntervalHours));
      }
      return t;
    }

    // Custom daily interval
    if (alarm.customIntervalDays > 0) {
      DateTime t = base;
      while (!t.isAfter(now)) {
        t = t.add(Duration(days: alarm.customIntervalDays));
      }
      return t;
    }

    // Weekly repeat days
    if (alarm.repeatDays.isNotEmpty) {
      // 0=Mon ... 6=Sun as per model
      int todayIndex = (now.weekday - 1) % 7; // DateTime.weekday: Mon=1..Sun=7
      for (int i = 0; i < 7; i++) {
        int idx = (todayIndex + i) % 7;
        if (alarm.repeatDays.contains(idx)) {
          DateTime candidate = base.add(Duration(days: i));
          if (candidate.isAfter(now)) return candidate;
        }
      }
      // fallback next week same earliest day
      int first = alarm.repeatDays.first;
      return base.add(Duration(days: (first - todayIndex + 7) % 7 + 7));
    }

    // This should not be reached for once alarms due to early return above
    if (base.isAfter(now)) return base;
    return base.add(const Duration(days: 1));
  }

  String _humanNextIn(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.inSeconds <= 0) return 'Ringing now';
    if (diff.inMinutes < 1) return 'In ${diff.inSeconds} sec';
    if (diff.inMinutes < 60) return 'In ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'In ${diff.inHours} hr';
    final days = diff.inDays;
    return days == 1 ? 'Tomorrow' : 'In $days days';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'Search labels...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text('Smart Alarm', style: TextStyle(color: Colors.white)),
        leading: _isSearching
            ? IconButton(
                color: Colors.white,
                tooltip: 'Close search',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : null,
        actions: [
          if (!_isSearching)
            IconButton(
              tooltip: 'Search',
              onPressed: () => setState(() => _isSearching = true),
              icon: const Icon(Icons.search, color: Colors.white),
            ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<AlarmBloc>().add(RefreshAlarms());
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            iconColor: Colors.white,
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'filter_all':
                    _filter = _AlarmFilter.all;
                    break;
                  case 'filter_active':
                    _filter = _AlarmFilter.active;
                    break;
                  case 'filter_inactive':
                    _filter = _AlarmFilter.inactive;
                    break;
                  case 'sort_time_asc':
                    _sort = _AlarmSort.timeAsc;
                    break;
                  case 'sort_time_desc':
                    _sort = _AlarmSort.timeDesc;
                    break;
                  case 'sort_label_asc':
                    _sort = _AlarmSort.labelAsc;
                    break;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'filter_all',
                child: Row(
                  children: const [
                    Icon(Icons.filter_alt_outlined, color: Colors.deepPurple),
                    SizedBox(width: 12),
                    Text('Show: All'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'filter_active',
                child: Row(
                  children: const [
                    Icon(Icons.toggle_on, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Show: Active'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'filter_inactive',
                child: Row(
                  children: const [
                    Icon(Icons.toggle_off, color: Colors.grey),
                    SizedBox(width: 12),
                    Text('Show: Inactive'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'sort_time_asc',
                child: Row(
                  children: const [
                    Icon(Icons.schedule, color: Colors.indigo),
                    SizedBox(width: 12),
                    Text('Sort: Time ↑'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_time_desc',
                child: Row(
                  children: const [
                    Icon(Icons.schedule, color: Colors.indigo),
                    SizedBox(width: 12),
                    Text('Sort: Time ↓'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_label_asc',
                child: Row(
                  children: const [
                    Icon(Icons.sort_by_alpha, color: Colors.teal),
                    SizedBox(width: 12),
                    Text('Sort: Label A-Z'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<AlarmBloc, AlarmState>(
        listener: (context, state) {
          if (state is AlarmError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
          if (state is AlarmLoading) {
            CircularProgressIndicator.adaptive();
          }
        },
        builder: (context, state) {
          if (state is AlarmLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (state is AlarmLoaded) {
            var alarms = List.of(state.alarms);
            // Filtering
            if (_filter != _AlarmFilter.all) {
              alarms = alarms
                  .where(
                    (a) => _filter == _AlarmFilter.active
                        ? a.isActive
                        : !a.isActive,
                  )
                  .toList();
            }
            // Searching
            final q = _searchController.text.trim().toLowerCase();
            if (q.isNotEmpty) {
              alarms = alarms
                  .where((a) => a.label.toLowerCase().contains(q))
                  .toList();
            }
            // Sorting
            switch (_sort) {
              case _AlarmSort.timeAsc:
                alarms.sort((a, b) => a.time.compareTo(b.time));
                break;
              case _AlarmSort.timeDesc:
                alarms.sort((a, b) => b.time.compareTo(a.time));
                break;
              case _AlarmSort.labelAsc:
                alarms.sort(
                  (a, b) =>
                      a.label.toLowerCase().compareTo(b.label.toLowerCase()),
                );
                break;
            }
            if (alarms.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.alarm_off, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Either no associated search results are found or no alarms is currently set.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to create your first alarm or create a new one with the label you searched for.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }
            alarms.sort((a, b) => a.time.compareTo(b.time));
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 30.0),
              child: ListView.builder(
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  final next = _nextOccurrence(alarm);
                  final bool isOnce = alarm.repeatDays.isEmpty &&
                      alarm.customIntervalDays == 0 &&
                      alarm.customIntervalHours == 0;
                  final bool isExpired =
                      isOnce && alarm.time.isBefore(DateTime.now());
                  final bool disableToggle = isExpired && !alarm.isActive;
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
                      color: Color.fromARGB(205, 255, 247, 203),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (alarm.label.isNotEmpty)
                                  Text(
                                    alarm.label,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: -4,
                                  children: [
                                    Chip(
                                      label: Text(
                                        _repeatInfo(alarm),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    if (disableToggle)
                                      Chip(
                                        backgroundColor: Colors.red.shade50,
                                        label: const Text(
                                          'Expired',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      )
                                    else
                                      Chip(
                                        backgroundColor: Colors.blue.shade50,
                                        label: Text(
                                          _humanNextIn(next),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              children: [
                                Switch(
                                  value: alarm.isActive,
                                  onChanged: disableToggle
                                      ? null
                                      : (val) {
                                          context.read<AlarmBloc>().add(
                                                ToggleAlarm(alarm.id, val),
                                              );
                                        },
                                ),
                                IconButton(
                                  tooltip: 'Edit',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddEditAlarmScreen(alarm: alarm),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
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
