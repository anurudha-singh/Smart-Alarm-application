import 'package:flutter/material.dart';

class RingingScreen extends StatelessWidget {
  final VoidCallback onStop;
  final VoidCallback onSnooze;
  final int snoozeMinutes;

  const RingingScreen({
    Key? key,
    required this.onStop,
    required this.onSnooze,
    this.snoozeMinutes = 5,
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onStop,
              child: const Text('Stop'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSnooze,
              child: Text('Snooze ($snoozeMinutes min)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
