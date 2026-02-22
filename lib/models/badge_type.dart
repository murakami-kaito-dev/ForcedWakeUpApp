import 'package:flutter/material.dart';

enum BadgeType {
  day1(
    requiredStreak: 1,
    icon: Icons.emoji_events,
    color: Colors.green,
    gradientColors: [Color(0xFF4CAF50), Color(0xFF81C784)],
  ),
  day3(
    requiredStreak: 3,
    icon: Icons.park,
    color: Colors.green,
    gradientColors: [Color(0xFF4CAF50), Color(0xFF81C784)],
  ),
  day7(
    requiredStreak: 7,
    icon: Icons.local_fire_department,
    color: Colors.orange,
    gradientColors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
  ),
  day14(
    requiredStreak: 14,
    icon: Icons.star,
    color: Colors.amber,
    gradientColors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
  ),
  day21(
    requiredStreak: 21,
    icon: Icons.trending_up,
    color: Colors.teal,
    gradientColors: [Color(0xFF009688), Color(0xFF4DB6AC)],
  ),
  day28(
    requiredStreak: 28,
    icon: Icons.calendar_month,
    color: Colors.cyan,
    gradientColors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
  ),
  day30(
    requiredStreak: 30,
    icon: Icons.looks_one,
    color: Colors.indigo,
    gradientColors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
  ),
  day40(
    requiredStreak: 40,
    icon: Icons.bolt,
    color: Colors.deepOrange,
    gradientColors: [Color(0xFFFF5722), Color(0xFFFF8A65)],
  ),
  day50(
    requiredStreak: 50,
    icon: Icons.diamond,
    color: Colors.blue,
    gradientColors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
  ),
  day60(
    requiredStreak: 60,
    icon: Icons.whatshot,
    color: Colors.red,
    gradientColors: [Color(0xFFF44336), Color(0xFFEF5350)],
  ),
  day70(
    requiredStreak: 70,
    icon: Icons.shield,
    color: Colors.brown,
    gradientColors: [Color(0xFF795548), Color(0xFFA1887F)],
  ),
  day80(
    requiredStreak: 80,
    icon: Icons.rocket_launch,
    color: Colors.pink,
    gradientColors: [Color(0xFFE91E63), Color(0xFFF06292)],
  ),
  day90(
    requiredStreak: 90,
    icon: Icons.military_tech,
    color: Colors.deepPurple,
    gradientColors: [Color(0xFF673AB7), Color(0xFF9575CD)],
  ),
  day100(
    requiredStreak: 100,
    icon: Icons.workspace_premium,
    color: Colors.purple,
    gradientColors: [Color(0xFF9C27B0), Color(0xFFFFD700)],
  ),
  day125(
    requiredStreak: 125,
    icon: Icons.auto_awesome,
    color: Colors.lime,
    gradientColors: [Color(0xFFCDDC39), Color(0xFFDCE775)],
  ),
  day150(
    requiredStreak: 150,
    icon: Icons.grade,
    color: Colors.amber,
    gradientColors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
  ),
  day175(
    requiredStreak: 175,
    icon: Icons.flash_on,
    color: Colors.yellow,
    gradientColors: [Color(0xFFFFEB3B), Color(0xFFFFF176)],
  ),
  day200(
    requiredStreak: 200,
    icon: Icons.emoji_events,
    color: Color(0xFFFFD700),
    gradientColors: [Color(0xFFFFD700), Color(0xFFFFF8E1)],
  ),
  day300(
    requiredStreak: 300,
    icon: Icons.castle,
    color: Colors.blueGrey,
    gradientColors: [Color(0xFF607D8B), Color(0xFF90A4AE)],
  ),
  day365(
    requiredStreak: 365,
    icon: Icons.cake,
    color: Colors.red,
    gradientColors: [Color(0xFFF44336), Color(0xFFFFD700)],
  ),
  day400(
    requiredStreak: 400,
    icon: Icons.public,
    color: Colors.lightBlue,
    gradientColors: [Color(0xFF03A9F4), Color(0xFF4FC3F7)],
  ),
  day500(
    requiredStreak: 500,
    icon: Icons.landscape,
    color: Colors.green,
    gradientColors: [Color(0xFF4CAF50), Color(0xFF81C784)],
  ),
  day600(
    requiredStreak: 600,
    icon: Icons.flare,
    color: Colors.orange,
    gradientColors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
  ),
  day700(
    requiredStreak: 700,
    icon: Icons.nightlight,
    color: Colors.indigo,
    gradientColors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
  ),
  day730(
    requiredStreak: 730,
    icon: Icons.celebration,
    color: Colors.purple,
    gradientColors: [Color(0xFF9C27B0), Color(0xFFFFD700)],
  ),
  day800(
    requiredStreak: 800,
    icon: Icons.cyclone,
    color: Colors.teal,
    gradientColors: [Color(0xFF009688), Color(0xFF4DB6AC)],
  ),
  day900(
    requiredStreak: 900,
    icon: Icons.volcano,
    color: Colors.deepOrange,
    gradientColors: [Color(0xFFFF5722), Color(0xFFFF8A65)],
  ),
  day1000(
    requiredStreak: 1000,
    icon: Icons.all_inclusive,
    color: Color(0xFFFFD700),
    gradientColors: [Color(0xFFFFD700), Color(0xFFFFF8E1)],
  ),
  day1095(
    requiredStreak: 1095,
    icon: Icons.stars,
    color: Colors.purple,
    gradientColors: [
      Color(0xFFFF0000),
      Color(0xFFFF9800),
      Color(0xFFFFEB3B),
      Color(0xFF4CAF50),
      Color(0xFF2196F3),
      Color(0xFF9C27B0),
    ],
  ),
  day1100(
    requiredStreak: 1100,
    icon: Icons.brightness_7,
    color: Colors.white,
    gradientColors: [Color(0xFFFFFFFF), Color(0xFFFFD700)],
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
