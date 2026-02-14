import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mission_type.dart';
import '../state/alarm_state.dart';
import '../state/language_state.dart';
import '../state/premium_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MissionCategory _selectedCategory = MissionCategory.workout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final langState = context.read<LanguageState>();
      if (langState.isFirstLaunch) {
        _showLanguageDialog();
      }
    });
  }

  void _showLanguageDialog() {
    final langState = context.read<LanguageState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '言語を選択 / Select Language',
          style: TextStyle(fontSize: 18, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  langState.setLanguage('ja');
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF533483),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('日本語',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  langState.setLanguage('en');
                  Navigator.pop(ctx);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF533483)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('English',
                    style: TextStyle(color: Color(0xFF533483), fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alarmState = context.watch<AlarmState>();
    final isPremium = context.watch<PremiumState>().isPremium;
    final s = context.watch<LanguageState>().strings;
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
                  Flexible(
                    child: Text(
                      s.appTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.language,
                            color: Colors.white70),
                        onPressed: _showLanguageDialog,
                      ),
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
                onTap: () => _showTimePicker(context, alarmState, s),
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  s.morningMission,
                  style: const TextStyle(
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
                  final catName = category == MissionCategory.workout
                      ? s.categoryWorkout
                      : s.categoryStudy;
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
                                catName,
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
              // Mission list
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
                                s.missionName(mission.id),
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
                                    _showMissionInfo(context, mission, s),
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
                      context, alarmState, selectedMission, s),
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
                          s.target,
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 14),
                        ),
                        Row(
                          children: [
                            Text(
                              '${settings.targetCount}${selectedMission.detectionMode == DetectionMode.repBased ? s.unitReps : s.unitSeconds}',
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
                  child: Text(
                    s.goodNight,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.doNotCloseApp,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissionInfo(
      BuildContext context, MissionType mission, dynamic s) {
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
              s.missionName(mission.id),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          s.missionInfo(mission.id),
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

  void _showTargetPicker(BuildContext context, AlarmState alarmState,
      MissionType mission, dynamic s) {
    final min = mission.minTarget;
    final max = mission.maxTarget;
    final current = alarmState.settings.targetCount.clamp(min, max);
    int selectedValue = current;
    final unit = mission.detectionMode == DetectionMode.repBased
        ? s.unitReps
        : s.unitSeconds;

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
                      child: Text(s.cancel,
                          style: const TextStyle(color: Colors.grey)),
                    ),
                    Text(
                      '${s.target} ($unit)',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        alarmState.updateTargetCount(selectedValue);
                        Navigator.pop(context);
                      },
                      child: Text(s.done,
                          style:
                              const TextStyle(color: Color(0xFF533483))),
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

  void _showTimePicker(
      BuildContext context, AlarmState alarmState, dynamic s) {
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
                      child: Text(s.cancel,
                          style: const TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        alarmState.updateAlarmTime(
                          TimeOfDay(
                              hour: selectedHour, minute: selectedMinute),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(s.done,
                          style:
                              const TextStyle(color: Color(0xFF533483))),
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
