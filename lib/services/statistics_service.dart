import '../models/mission_log.dart';
import 'database_service.dart';

class StatisticsService {
  final DatabaseService _db;

  StatisticsService(this._db);

  Future<void> logResult({
    required String missionId,
    required String result,
    required int target,
    required int achieved,
    required int durationSeconds,
  }) async {
    final now = DateTime.now();
    final log = MissionLog(
      date: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      missionId: missionId,
      result: result,
      target: target,
      achieved: achieved,
      durationSeconds: durationSeconds,
      createdAt: now.toIso8601String(),
    );
    await _db.insertLog(log);
  }

  Future<int> getCurrentStreak() async {
    final dates = await _db.getSuccessDates();
    if (dates.isEmpty) return 0;

    int streak = 0;
    var checkDate = DateTime.now();

    // Check today first
    final todayStr = _formatDate(checkDate);
    if (!dates.contains(todayStr)) {
      // Check if yesterday has a success (streak might still be active)
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final dateStr = _formatDate(checkDate);
      if (dates.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Future<int> getBestStreak() async {
    final dates = await _db.getSuccessDates();
    if (dates.isEmpty) return 0;

    int bestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      final prev = DateTime.parse(dates[i - 1]);
      final curr = DateTime.parse(dates[i]);
      final diff = curr.difference(prev).inDays;

      if (diff == 1) {
        currentStreak++;
        if (currentStreak > bestStreak) bestStreak = currentStreak;
      } else if (diff > 1) {
        currentStreak = 1;
      }
    }
    return bestStreak;
  }

  Future<Map<String, int>> getMonthlyStats(int year, int month) async {
    final startDate =
        '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(year, month + 1, 0).day;
    final endDate =
        '$year-${month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';

    final logs = await _db.getLogsByDateRange(startDate, endDate);
    final total = logs.length;
    final successes = logs.where((l) => l.result == 'success').length;

    return {
      'total': total,
      'successes': successes,
      'failures': total - successes,
    };
  }

  Future<Set<DateTime>> getSuccessDatesAsDateTime() async {
    final dates = await _db.getSuccessDates();
    return dates.map((d) => DateTime.parse(d)).toSet();
  }

  Future<Map<String, int>> getMissionBreakdown() async {
    final logs = await _db.getAllLogs();
    final breakdown = <String, int>{};
    for (final log in logs.where((l) => l.result == 'success')) {
      breakdown[log.missionId] = (breakdown[log.missionId] ?? 0) + 1;
    }
    return breakdown;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
