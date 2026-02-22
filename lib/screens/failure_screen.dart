import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/share_edit_sheet.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/statistics_service.dart';
import '../state/alarm_state.dart';
import '../state/language_state.dart';
import '../theme/app_colors.dart';

class FailureScreen extends StatefulWidget {
  final StatisticsService statisticsService;

  const FailureScreen({super.key, required this.statisticsService});

  @override
  State<FailureScreen> createState() => _FailureScreenState();
}

class _FailureScreenState extends State<FailureScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    WakelockPlus.disable();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _logFailure();
  }

  Future<void> _logFailure() async {
    final alarmState = context.read<AlarmState>();
    final triggeredAt = alarmState.alarmTriggeredAt;
    final durationSeconds = triggeredAt != null
        ? DateTime.now().difference(triggeredAt).inSeconds
        : 0;

    await widget.statisticsService.logResult(
      missionId: alarmState.settings.missionTypeId,
      result: 'failure',
      target: alarmState.targetCount,
      achieved: alarmState.completedCount,
      durationSeconds: durationSeconds,
    );

    final streak = await widget.statisticsService.getCurrentStreak();
    if (mounted) {
      setState(() {
        _currentStreak = streak;
      });
    }
  }

  void _shareAchievement() {
    final s = context.read<LanguageState>().strings;
    ShareEditSheet.show(context,
        defaultText: s.shareText(_currentStreak), strings: s);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageState>().strings;

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
                  scale: _scaleAnimation,
                  child: const Icon(
                    Icons.nights_stay,
                    color: AppColors.textSecondary,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Column(
                    children: [
                      Text(
                        s.missionFailed,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.tryAgainTomorrow,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      if (_currentStreak > 0) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department,
                                  color: Colors.orangeAccent, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                s.streakDays(_currentStreak),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _shareAchievement,
                          icon: const Icon(Icons.share,
                              color: AppColors.accent),
                          label: Text(
                            s.share,
                            style: const TextStyle(color: AppColors.accent),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 200,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AlarmState>().resetAlarm();
                            Navigator.pushReplacementNamed(context, '/');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            s.backToHome,
                            style: const TextStyle(
                              color: AppColors.surface,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
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
