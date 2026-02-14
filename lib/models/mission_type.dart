import 'package:flutter/material.dart';

enum MissionCategory {
  workout,
  study;

  String get displayName {
    switch (this) {
      case MissionCategory.workout:
        return '運動';
      case MissionCategory.study:
        return '勉強';
    }
  }

  IconData get icon {
    switch (this) {
      case MissionCategory.workout:
        return Icons.fitness_center;
      case MissionCategory.study:
        return Icons.menu_book;
    }
  }
}

enum DetectionMode {
  repBased,
  durationBased,
}

sealed class MissionType {
  final String id;
  final String displayName;
  final IconData icon;
  final MissionCategory category;
  final bool isPremium;
  final DetectionMode detectionMode;
  final int defaultTarget;
  final int minTarget;
  final int maxTarget;

  const MissionType({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.category,
    required this.isPremium,
    required this.detectionMode,
    required this.defaultTarget,
    required this.minTarget,
    required this.maxTarget,
  });

  String get targetUnit => detectionMode == DetectionMode.repBased ? '回' : '秒';

  static const List<MissionType> all = [
    SquatMission(),
    PushUpMission(),
    BurpeeMission(),
    ReadingMission(),
    StudyingMission(),
  ];

  static List<MissionType> byCategory(MissionCategory category) =>
      all.where((m) => m.category == category).toList();

  static MissionType fromId(String id) =>
      all.firstWhere((m) => m.id == id, orElse: () => const SquatMission());
}

class SquatMission extends MissionType {
  const SquatMission()
      : super(
          id: 'squat',
          displayName: 'スクワット',
          icon: Icons.accessibility_new,
          category: MissionCategory.workout,
          isPremium: false,
          detectionMode: DetectionMode.repBased,
          defaultTarget: 10,
          minTarget: 5,
          maxTarget: 50,
        );
}

class PushUpMission extends MissionType {
  const PushUpMission()
      : super(
          id: 'pushUp',
          displayName: '腕立て伏せ',
          icon: Icons.fitness_center,
          category: MissionCategory.workout,
          isPremium: false,
          detectionMode: DetectionMode.repBased,
          defaultTarget: 10,
          minTarget: 5,
          maxTarget: 30,
        );
}

class BurpeeMission extends MissionType {
  const BurpeeMission()
      : super(
          id: 'burpee',
          displayName: 'バーピー',
          icon: Icons.sports_gymnastics,
          category: MissionCategory.workout,
          isPremium: true,
          detectionMode: DetectionMode.repBased,
          defaultTarget: 5,
          minTarget: 3,
          maxTarget: 20,
        );
}

class ReadingMission extends MissionType {
  const ReadingMission()
      : super(
          id: 'reading',
          displayName: '読書',
          icon: Icons.auto_stories,
          category: MissionCategory.study,
          isPremium: true,
          detectionMode: DetectionMode.durationBased,
          defaultTarget: 5,
          minTarget: 5,
          maxTarget: 5,
        );
}

class StudyingMission extends MissionType {
  const StudyingMission()
      : super(
          id: 'studying',
          displayName: '勉強',
          icon: Icons.edit_note,
          category: MissionCategory.study,
          isPremium: true,
          detectionMode: DetectionMode.durationBased,
          defaultTarget: 5,
          minTarget: 5,
          maxTarget: 5,
        );
}
