import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission_type.dart';
import '../services/audio_service.dart';
import '../services/statistics_service.dart';
import '../state/alarm_state.dart';
import '../state/language_state.dart';
import '../theme/app_colors.dart';

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
    final s = context.watch<LanguageState>().strings;
    final mission = alarmState.missionType;

    String instructionText;
    switch (mission.id) {
      case 'reading':
        instructionText =
            s.alarmInstructionReading(alarmState.targetCount);
      case 'studying':
        instructionText =
            s.alarmInstructionStudying(alarmState.targetCount);
      default:
        instructionText = s.alarmInstructionExercise(
            s.missionName(mission.id), alarmState.targetCount);
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                Text(
                  s.wakeUpTime,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
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
                      color: AppColors.textSecondary,
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
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      mission.category == MissionCategory.workout
                          ? s.startExercise
                          : s.start,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  s.brightPlace,
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
                if (mission.category == MissionCategory.workout) ...[
                  const SizedBox(height: 8),
                  Text(
                    s.recommendStand,
                    style: const TextStyle(color: AppColors.textHint, fontSize: 12),
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
