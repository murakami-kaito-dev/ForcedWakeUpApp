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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'アラームを解除しますか？',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: const Text(
          'ホーム画面に戻ります。',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _timer?.cancel();
              WakelockPlus.disable();
              Navigator.pushReplacementNamed(this.context, '/');
            },
            child: const Text('解除する',
                style: TextStyle(color: Color(0xFFE94560))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.nightlight_round,
                    color: Colors.white.withOpacity(0.3),
                    size: 48,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _countdown,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 56,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '充電しておやすみください',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Colors.white.withOpacity(0.5)),
                onPressed: () => _showCancelDialog(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
