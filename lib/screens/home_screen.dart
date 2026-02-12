import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise_type.dart';
import '../state/alarm_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alarmState = context.watch<AlarmState>();
    final settings = alarmState.settings;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                '朝型強制変換アラーム',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '筋トレしないと止まらない',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),
              // Alarm time picker
              GestureDetector(
                onTap: () => _showTimePicker(context, alarmState),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${settings.alarmTime.hour.toString().padLeft(2, '0')}:${settings.alarmTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Exercise type selector
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '解除種目',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: ExerciseType.values.map((type) {
                  final isSelected = settings.exerciseType == type;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: type == ExerciseType.squat ? 8 : 0,
                        left: type == ExerciseType.pushUp ? 8 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => alarmState.updateExerciseType(type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                          child: Column(
                            children: [
                              Icon(
                                type == ExerciseType.squat
                                    ? Icons.accessibility_new
                                    : Icons.fitness_center,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                type.displayName,
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
                              const SizedBox(height: 4),
                              Text(
                                '10回',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white60
                                      : Colors.grey[700],
                                  fontSize: 12,
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
              const Spacer(),
              // Oyasumi button
              SizedBox(
                width: double.infinity,
                height: 60,
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
              const SizedBox(height: 16),
              Text(
                'アプリを閉じないでください',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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
                    2024,
                    1,
                    1,
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
