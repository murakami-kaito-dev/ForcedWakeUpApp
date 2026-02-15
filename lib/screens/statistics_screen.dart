import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/badge_type.dart';
import '../models/mission_type.dart';
import '../services/badge_service.dart';
import '../services/statistics_service.dart';
import '../state/language_state.dart';
import '../state/premium_state.dart';
import '../theme/app_colors.dart';
import '../widgets/badge_earned_dialog.dart';
import '../widgets/badge_widget.dart';

class StatisticsScreen extends StatefulWidget {
  final StatisticsService statisticsService;

  const StatisticsScreen({super.key, required this.statisticsService});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _currentStreak = 0;
  int _bestStreak = 0;
  Map<String, int> _monthlyStats = {};
  Map<String, int> _missionBreakdown = {};
  Set<DateTime> _successDates = {};
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final now = DateTime.now();
    final results = await Future.wait([
      widget.statisticsService.getCurrentStreak(),
      widget.statisticsService.getBestStreak(),
      widget.statisticsService.getMonthlyStats(now.year, now.month),
      widget.statisticsService.getMissionBreakdown(),
      widget.statisticsService.getSuccessDatesAsDateTime(),
    ]);

    setState(() {
      _currentStreak = results[0] as int;
      _bestStreak = results[1] as int;
      _monthlyStats = results[2] as Map<String, int>;
      _missionBreakdown = results[3] as Map<String, int>;
      _successDates = results[4] as Set<DateTime>;
    });

    if (!mounted) return;
    final isPremium = context.read<PremiumState>().isPremium;
    if (!isPremium) return;

    final badgeService = context.read<BadgeService>();
    await badgeService.loadBadges();
    final newBadges = await badgeService.checkAndUnlockBadges(_bestStreak);
    if (newBadges.isNotEmpty && mounted) {
      final s = context.read<LanguageState>().strings;
      for (final badge in newBadges) {
        await showDialog(
          context: context,
          builder: (_) => BadgeEarnedDialog(
            badge: badge,
            streak: _bestStreak,
            strings: s,
          ),
        );
      }
    }
  }

  Widget _buildBadgeSection(dynamic s) {
    final badgeService = context.watch<BadgeService>();
    final unlocked = badgeService.unlockedBadges;
    final unlockDates = badgeService.unlockDates;
    final latestBadge = unlocked.isNotEmpty ? unlocked.last : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.badgesTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: BadgeType.values.map((badge) {
              final isUnlocked = unlocked.contains(badge);
              final isLatest = badge == latestBadge;
              final unlockDate = unlockDates[badge];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    BadgeWidget(
                      badge: badge,
                      unlocked: isUnlocked,
                      isLatest: isLatest,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isUnlocked
                          ? s.badgeName(badge.name)
                          : s.badgeUnlockCondition(badge.requiredStreak),
                      style: TextStyle(
                        color: isUnlocked
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                        fontSize: 11,
                        fontWeight:
                            isUnlocked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isUnlocked && unlockDate != null)
                      Text(
                        s.unlockedAt(
                          '${unlockDate.month}/${unlockDate.day}',
                        ),
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageState>().strings;
    final successRate = _monthlyStats['total'] != null &&
            _monthlyStats['total']! > 0
        ? ((_monthlyStats['successes'] ?? 0) / _monthlyStats['total']! * 100)
            .round()
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(s.statistics,
            style: const TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: s.currentStreak,
                    value: s.daysSuffix(_currentStreak),
                    icon: Icons.local_fire_department,
                    color: Colors.orangeAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: s.bestStreak,
                    value: s.daysSuffix(_bestStreak),
                    icon: Icons.emoji_events,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: s.monthlySuccessRate,
                    value: '$successRate%',
                    icon: Icons.trending_up,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: s.monthlyAttempts,
                    value: s.timesSuffix(_monthlyStats['total'] ?? 0),
                    icon: Icons.repeat,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            if (context.watch<PremiumState>().isPremium) ...[
              const SizedBox(height: 24),
              _buildBadgeSection(s),
            ],
            const SizedBox(height: 24),
            // Calendar
            Text(
              s.calendar,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TableCalendar(
                firstDay: DateTime(2024),
                lastDay: DateTime.now().add(const Duration(days: 1)),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                daysOfWeekHeight: 24,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: AppColors.textSecondary),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppColors.textHint),
                  weekendStyle: TextStyle(color: AppColors.textHint),
                ),
                calendarStyle: const CalendarStyle(
                  defaultTextStyle:
                      TextStyle(color: AppColors.textSecondary),
                  weekendTextStyle:
                      TextStyle(color: AppColors.textSecondary),
                  outsideTextStyle: TextStyle(color: AppColors.textHint),
                  todayDecoration: BoxDecoration(
                    color: AppColors.selected,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  final normalized =
                      DateTime(day.year, day.month, day.day);
                  return _successDates.contains(normalized)
                      ? ['success']
                      : [];
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
              ),
            ),
            const SizedBox(height: 24),
            // Mission breakdown
            if (_missionBreakdown.isNotEmpty) ...[
              Text(
                s.missionBreakdown,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._missionBreakdown.entries.map((entry) {
                final mission = MissionType.fromId(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(mission.icon,
                            color: AppColors.textSecondary, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          s.missionName(mission.id),
                          style:
                              const TextStyle(color: AppColors.textPrimary),
                        ),
                        const Spacer(),
                        Text(
                          s.timesSuffix(entry.value),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label,
              style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
        ],
      ),
    );
  }
}
