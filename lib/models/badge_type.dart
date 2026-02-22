import 'package:flutter/material.dart';

enum BadgeType {
  sprout(
    requiredStreak: 3,
    icon: Icons.park,
    color: Colors.green,
    gradientColors: [Color(0xFF4CAF50), Color(0xFF81C784)],
  ),
  startDash(
    requiredStreak: 7,
    icon: Icons.local_fire_department,
    color: Colors.orange,
    gradientColors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
  ),
  routine(
    requiredStreak: 14,
    icon: Icons.star,
    color: Colors.amber,
    gradientColors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
  ),
  master(
    requiredStreak: 50,
    icon: Icons.diamond,
    color: Colors.blue,
    gradientColors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
  ),
  legend(
    requiredStreak: 100,
    icon: Icons.workspace_premium,
    color: Colors.purple,
    gradientColors: [Color(0xFF9C27B0), Color(0xFFFFD700)],
  );

  final int requiredStreak;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  const BadgeType({
    required this.requiredStreak,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });

  static BadgeType? fromId(String id) {
    try {
      return BadgeType.values.firstWhere((b) => b.name == id);
    } catch (_) {
      return null;
    }
  }
}
