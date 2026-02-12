import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../state/alarm_state.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  Timer? _autoStopTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _audioService.playAlarm();

    // 10 minute auto-stop
    _autoStopTimer = Timer(const Duration(minutes: 10), () {
      _audioService.stopAlarm();
      if (mounted) {
        context.read<AlarmState>().resetAlarm();
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    _pulseController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alarmState = context.watch<AlarmState>();
    final exerciseName = alarmState.settings.exerciseType.displayName;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: const Icon(
                    Icons.alarm,
                    color: Colors.redAccent,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '起きる時間です！',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$exerciseNameを10回行ってアラームを解除',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 240,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/exercise');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF533483),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '筋トレを始める',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '明るい場所で行ってください',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'スマホスタンドの使用を推奨します',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
