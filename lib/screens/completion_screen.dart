import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/statistics_service.dart';
import '../state/alarm_state.dart';
import '../state/premium_state.dart';

class CompletionScreen extends StatefulWidget {
  final StatisticsService statisticsService;

  const CompletionScreen({super.key, required this.statisticsService});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  int _currentStreak = 0;
  bool _isShareMilestone = false;

  static const _milestones = [3, 7, 14, 30, 50, 100];

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
    _logAndCheckStreak();
  }

  Future<void> _logAndCheckStreak() async {
    final alarmState = context.read<AlarmState>();
    final triggeredAt = alarmState.alarmTriggeredAt;
    final durationSeconds = triggeredAt != null
        ? DateTime.now().difference(triggeredAt).inSeconds
        : 0;

    await widget.statisticsService.logResult(
      missionId: alarmState.settings.missionTypeId,
      result: 'success',
      target: alarmState.targetCount,
      achieved: alarmState.completedCount,
      durationSeconds: durationSeconds,
    );

    final streak = await widget.statisticsService.getCurrentStreak();
    if (mounted) {
      setState(() {
        _currentStreak = streak;
        _isShareMilestone = _milestones.contains(streak);
      });
    }
  }

  void _shareAchievement() {
    final text = '朝型強制変換アラームで$_currentStreak日連続起床達成！\n運動しないと止まらないアラームで朝型生活を継続中';
    Share.share(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumState>().isPremium;

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
                  scale: _scaleAnimation,
                  child: const Icon(
                    Icons.wb_sunny,
                    color: Color(0xFFFFD700),
                    size: 100,
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'おはようございます！',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '素晴らしい！今日も良い一日を。',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      if (_currentStreak > 0) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16213E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department,
                                  color: Colors.orangeAccent, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                '$_currentStreak日連続',
                                style: const TextStyle(
                                  color: Colors.white,
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
                      if (_isShareMilestone && isPremium) ...[
                        SizedBox(
                          width: 200,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _shareAchievement,
                            icon: const Icon(Icons.share,
                                color: Color(0xFF533483)),
                            label: const Text(
                              'シェアする',
                              style: TextStyle(color: Color(0xFF533483)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF533483)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: 200,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AlarmState>().resetAlarm();
                            Navigator.pushReplacementNamed(context, '/');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF533483),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'ホームに戻る',
                            style: TextStyle(
                              color: Colors.white,
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
