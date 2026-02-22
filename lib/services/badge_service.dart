import 'package:flutter/foundation.dart';
import '../models/badge_type.dart';
import 'database_service.dart';

class BadgeService extends ChangeNotifier {
  final DatabaseService _db;
  List<BadgeType> _unlockedBadges = [];
  Map<BadgeType, DateTime> _unlockDates = {};

  BadgeService(this._db);

  List<BadgeType> get unlockedBadges => _unlockedBadges;
  Map<BadgeType, DateTime> get unlockDates => _unlockDates;

  Future<void> loadBadges() async {
    final rows = await _db.getUnlockedBadges();
    _unlockedBadges = [];
    _unlockDates = {};
    for (final row in rows) {
      final badge = BadgeType.fromId(row['badge_type'] as String);
      if (badge != null) {
        _unlockedBadges.add(badge);
        _unlockDates[badge] = DateTime.parse(row['unlocked_at'] as String);
      }
    }
    notifyListeners();
  }

  Future<List<BadgeType>> checkAndUnlockBadges(int bestStreak) async {
    final newlyUnlocked = <BadgeType>[];
    for (final badge in BadgeType.values) {
      if (bestStreak >= badge.requiredStreak &&
          !_unlockedBadges.contains(badge)) {
        await _db.insertBadge(badge.name);
        _unlockedBadges.add(badge);
        _unlockDates[badge] = DateTime.now();
        newlyUnlocked.add(badge);
      }
    }
    if (newlyUnlocked.isNotEmpty) {
      notifyListeners();
    }
    return newlyUnlocked;
  }
}
