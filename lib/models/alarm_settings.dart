import 'dart:convert';
import 'package:flutter/material.dart';
import 'exercise_type.dart';

class AlarmSettings {
  final TimeOfDay alarmTime;
  final ExerciseType exerciseType;
  final bool isEnabled;

  const AlarmSettings({
    required this.alarmTime,
    required this.exerciseType,
    this.isEnabled = true,
  });

  AlarmSettings copyWith({
    TimeOfDay? alarmTime,
    ExerciseType? exerciseType,
    bool? isEnabled,
  }) {
    return AlarmSettings(
      alarmTime: alarmTime ?? this.alarmTime,
      exerciseType: exerciseType ?? this.exerciseType,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': alarmTime.hour,
      'minute': alarmTime.minute,
      'exerciseType': exerciseType.index,
      'isEnabled': isEnabled,
    };
  }

  factory AlarmSettings.fromJson(Map<String, dynamic> json) {
    return AlarmSettings(
      alarmTime: TimeOfDay(hour: json['hour'], minute: json['minute']),
      exerciseType: ExerciseType.values[json['exerciseType']],
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AlarmSettings.fromJsonString(String jsonString) {
    return AlarmSettings.fromJson(jsonDecode(jsonString));
  }

  static AlarmSettings get defaultSettings => const AlarmSettings(
        alarmTime: TimeOfDay(hour: 7, minute: 0),
        exerciseType: ExerciseType.squat,
      );
}
