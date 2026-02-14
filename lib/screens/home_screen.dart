import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission_type.dart';
import '../state/alarm_state.dart';
import '../state/premium_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MissionCategory _selectedCategory = MissionCategory.workout;

  @override
  Widget build(BuildContext context) {
    final alarmState = context.watch<AlarmState>();
    final isPremium = context.watch<PremiumState>().isPremium;
    final settings = alarmState.settings;
    final selectedMission = alarmState.missionType;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Header with stats button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '朝型強制変換アラーム',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.bar_chart,
                            color: Colors.white70),
                        onPressed: () {
                          if (!isPremium) {
                            Navigator.pushNamed(context, '/paywall');
                            return;
                          }
                          Navigator.pushNamed(context, '/statistics');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.music_note,
                            color: Colors.white70),
                        onPressed: () {
                          Navigator.pushNamed(context, '/sound-selection');
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Alarm time picker
              GestureDetector(
                onTap: () => _showTimePicker(context, alarmState),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${settings.alarmTime.hour.toString().padLeft(2, '0')}:${settings.alarmTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Mission section header
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'モーニングミッション',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Category tabs
              Row(
                children: MissionCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: category == MissionCategory.workout ? 6 : 0,
                        left: category == MissionCategory.study ? 6 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF533483)
                                : const Color(0xFF16213E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(category.icon,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                  size: 18),
                              const SizedBox(width: 6),
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              // Mission list (type selection only, no count displayed)
              Expanded(
                child: ListView(
                  children: MissionType.byCategory(_selectedCategory)
                      .map((mission) {
                    final isSelected =
                        settings.missionTypeId == mission.id;
                    final isLocked = mission.isPremium && !isPremium;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          if (isLocked) {
                            Navigator.pushNamed(context, '/paywall');
                            return;
                          }
                          alarmState.updateMissionType(mission.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0F3460)
                                : const Color(0xFF16213E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF533483)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                mission.icon,
                                color: isLocked
                                    ? Colors.grey[700]
                                    : isSelected
                                        ? Colors.white
                                        : Colors.grey[500],
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                mission.displayName,
                                style: TextStyle(
                                  color: isLocked
                                      ? Colors.grey[700]
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isLocked) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.lock,
                                    color: Colors.grey, size: 14),
                              ],
                              if (mission.isPremium && isPremium) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.star,
                                    color: Color(0xFFFFD700), size: 14),
                              ],
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () =>
                                    _showMissionInfo(context, mission),
                                child: Icon(Icons.info_outline,
                                    color: Colors.grey[600], size: 18),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF533483)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Target count picker (only for rep-based missions)
              if (selectedMission.detectionMode == DetectionMode.repBased)
                GestureDetector(
                  onTap: () => _showTargetPicker(
                      context, alarmState, selectedMission),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '目標',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 14),
                        ),
                        Row(
                          children: [
                            Text(
                              '${settings.targetCount}${selectedMission.targetUnit}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right,
                                color: Colors.grey[600], size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // Oyasumi button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/sleep');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF533483),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'おやすみ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'アプリを閉じないでください',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissionInfo(BuildContext context, MissionType mission) {
    String description;
    switch (mission.id) {
      case 'squat':
        description =
            'カメラの前でスクワットをしてください。\n\n全身が映るようにスマホを置き、膝の曲げ伸ばしが検出されると1回カウントされます。';
      case 'pushUp':
        description =
            'カメラの前で腕立て伏せをしてください。\n\n上半身が映るようにスマホを置き、腕の曲げ伸ばしが検出されると1回カウントされます。';
      case 'burpee':
        description =
            'カメラの前でバーピーをしてください。\n\n全身が映るようにスマホを置き、しゃがむ→伏せる→立ち上がるの動作が検出されると1回カウントされます。';
      case 'reading':
        description =
            '本や参考書をカメラに映してください。\n\n背面カメラで本を映し続けると、検出されている間タイマーが進みます。';
      case 'studying':
        description =
            'ペンをカメラに映してください。\n\n背面カメラでペンなどの文房具を映すと、検出されている間タイマーが進みます。';
      default:
        description = '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(mission.icon, color: const Color(0xFF533483), size: 24),
            const SizedBox(width: 8),
            Text(
              mission.displayName,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          description,
          style: const TextStyle(
            color: Color(0xFF444444),
            fontSize: 14,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: Color(0xFF533483))),
          ),
        ],
      ),
    );
  }

  void _showTargetPicker(
      BuildContext context, AlarmState alarmState, MissionType mission) {
    final min = mission.minTarget;
    final max = mission.maxTarget;
    final current = alarmState.settings.targetCount.clamp(min, max);
    int selectedValue = current;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('キャンセル',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    Text(
                      '目標 (${mission.targetUnit})',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        alarmState.updateTargetCount(selectedValue);
                        Navigator.pop(context);
                      },
                      child: const Text('設定',
                          style: TextStyle(color: Color(0xFF533483))),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: current - min,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    selectedValue = min + index;
                  },
                  children: List.generate(
                    max - min + 1,
                    (index) => Center(
                      child: Text(
                        '${min + index}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTimePicker(BuildContext context, AlarmState alarmState) {
    final settings = alarmState.settings;
    int selectedHour = settings.alarmTime.hour;
    int selectedMinute = settings.alarmTime.minute;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('キャンセル',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        alarmState.updateAlarmTime(
                          TimeOfDay(
                              hour: selectedHour, minute: selectedMinute),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('設定',
                          style: TextStyle(color: Color(0xFF533483))),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(
                    2024, 1, 1,
                    settings.alarmTime.hour,
                    settings.alarmTime.minute,
                  ),
                  onDateTimeChanged: (dateTime) {
                    selectedHour = dateTime.hour;
                    selectedMinute = dateTime.minute;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
