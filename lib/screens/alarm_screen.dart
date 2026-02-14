import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission_type.dart';
import '../services/audio_service.dart';
import '../services/statistics_service.dart';
import '../state/alarm_state.dart';

class AlarmScreen extends StatefulWidget {
  final StatisticsService statisticsService;

  const AlarmScreen({super.key, required this.statisticsService});

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

    final settings = context.read<AlarmState>().settings;
    _audioService.playAlarm(
      soundId: settings.alarmSoundId,
      volume: settings.alarmVolume,
      customSoundPath: settings.customSoundPath,
    );

    // 10 minute auto-stop
    _autoStopTimer = Timer(const Duration(minutes: 10), () {
      _audioService.stopAlarm();
      if (mounted) {
        final alarmState = context.read<AlarmState>();
        // Log failure
        widget.statisticsService.logResult(
          missionId: alarmState.settings.missionTypeId,
          result: 'failure',
          target: alarmState.targetCount,
          achieved: alarmState.completedCount,
          durationSeconds: 600,
        );
        alarmState.resetAlarm();
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
    final mission = alarmState.missionType;
    String instructionText;
    switch (mission.id) {
      case 'reading':
        instructionText = '本や参考書を${alarmState.targetCount}秒カメラに映してアラームを解除';
      case 'studying':
        instructionText = 'ペンを${alarmState.targetCount}秒カメラに映してアラームを解除';
      default:
        instructionText =
            '${mission.displayName}を${alarmState.targetCount}回行ってアラームを解除';
    }

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    instructionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
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
                    child: Text(
                      mission.category == MissionCategory.workout
                          ? '運動を始める'
                          : '始める',
                      style: const TextStyle(
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
                if (mission.category == MissionCategory.workout) ...[
                  const SizedBox(height: 8),
                  Text(
                    'スマホスタンドの使用を推奨します',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
