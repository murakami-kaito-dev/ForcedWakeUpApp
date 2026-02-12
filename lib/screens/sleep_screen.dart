import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../state/alarm_state.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  Timer? _timer;
  String _countdown = '';

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  DateTime _getNextAlarmDateTime(TimeOfDay alarmTime) {
    final now = DateTime.now();
    var alarm = DateTime(
        now.year, now.month, now.day, alarmTime.hour, alarmTime.minute);
    if (alarm.isBefore(now)) {
      alarm = alarm.add(const Duration(days: 1));
    }
    return alarm;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      final alarmState = context.read<AlarmState>();
      final alarmDateTime =
          _getNextAlarmDateTime(alarmState.settings.alarmTime);
      final now = DateTime.now();
      final diff = alarmDateTime.difference(now);

      if (diff.isNegative || diff.inSeconds <= 0) {
        _timer?.cancel();
        alarmState.triggerAlarm();
        Navigator.pushReplacementNamed(context, '/alarm');
        return;
      }

      setState(() {
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        final seconds = diff.inSeconds % 60;
        _countdown =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _countdown,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.15),
                    fontSize: 48,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '充電しておやすみください',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.1),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
