import 'package:flutter/material.dart';

class RingingScreen extends StatelessWidget {
  final VoidCallback onStop;
  final VoidCallback onSnooze;
  final int snoozeMinutes;
  final String label;

  const RingingScreen({
    Key? key,
    required this.onStop,
    required this.onSnooze,
    this.label = '',
    this.snoozeMinutes = 5, //Added default time for snooze
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm, size: 100, color: Colors.white),
            const SizedBox(height: 32),
            const Text(
              'Alarm Ringing!',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.white70),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onStop,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Stop'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSnooze,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Snooze ($snoozeMinutes min)'),
            ),
          ],
        ),
      ),
    );
  }
}
