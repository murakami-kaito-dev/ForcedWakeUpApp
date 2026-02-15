import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mission_log.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'forced_wakeup.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mission_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            mission_id TEXT NOT NULL,
            result TEXT NOT NULL,
            target INTEGER NOT NULL,
            achieved INTEGER NOT NULL,
            duration_seconds INTEGER NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_mission_log_date ON mission_log(date)',
        );
        await db.execute('''
          CREATE TABLE badges (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            badge_type TEXT NOT NULL UNIQUE,
            unlocked_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertBadge(String badgeType) async {
    final db = await database;
    await db.insert(
      'badges',
      {
        'badge_type': badgeType,
        'unlocked_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Map<String, dynamic>>> getUnlockedBadges() async {
    final db = await database;
    return await db.query('badges', orderBy: 'unlocked_at ASC');
  }

  Future<int> insertLog(MissionLog log) async {
    final db = await database;
    return await db.insert('mission_log', log.toMap());
  }

  Future<List<MissionLog>> getLogsByDateRange(
      String startDate, String endDate) async {
    final db = await database;
    final results = await db.query(
      'mission_log',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
    return results.map((m) => MissionLog.fromMap(m)).toList();
  }

  Future<List<MissionLog>> getAllLogs() async {
    final db = await database;
    final results = await db.query('mission_log', orderBy: 'date DESC');
    return results.map((m) => MissionLog.fromMap(m)).toList();
  }

  Future<List<String>> getSuccessDates() async {
    final db = await database;
    final results = await db.query(
      'mission_log',
      columns: ['DISTINCT date'],
      where: "result = 'success'",
      orderBy: 'date ASC',
    );
    return results.map((r) => r['date'] as String).toList();
  }
}
