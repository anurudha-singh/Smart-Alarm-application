import 'dart:async';
import 'package:flutter/material.dart';
import 'alarm_dashboard_screen.dart';

class SplashOrHome extends StatefulWidget {
  const SplashOrHome({Key? key}) : super(key: key);

  @override
  State<SplashOrHome> createState() => _SplashOrHomeState();
}

class _SplashOrHomeState extends State<SplashOrHome> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/iqonoic_logo.png',
                width: 120,
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to Smart Alarm App',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),
              const Text(
                'by Anurudha Singh',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    } else {
      return const AlarmDashboardScreen();
    }
  }
}
