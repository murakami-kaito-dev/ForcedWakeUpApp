import 'dart:convert';
import 'package:flutter/material.dart';
import 'mission_type.dart';

class AlarmSettings {
  final TimeOfDay alarmTime;
  final String missionTypeId;
  final bool isEnabled;
  final int targetCount;
  final String alarmSoundId;
  final double alarmVolume;
  final String? customSoundPath;
  final String? customSoundName;

  AlarmSettings({
    required this.alarmTime,
    required this.missionTypeId,
    this.isEnabled = true,
    int? targetCount,
    this.alarmSoundId = 'fanfare',
    this.alarmVolume = 1.0,
    this.customSoundPath,
    this.customSoundName,
  }) : targetCount =
            targetCount ?? MissionType.fromId(missionTypeId).defaultTarget;

  MissionType get missionType => MissionType.fromId(missionTypeId);

  AlarmSettings copyWith({
    TimeOfDay? alarmTime,
    String? missionTypeId,
    bool? isEnabled,
    int? targetCount,
    String? alarmSoundId,
    double? alarmVolume,
    String? customSoundPath,
    String? customSoundName,
  }) {
    return AlarmSettings(
      alarmTime: alarmTime ?? this.alarmTime,
      missionTypeId: missionTypeId ?? this.missionTypeId,
      isEnabled: isEnabled ?? this.isEnabled,
      targetCount: targetCount ?? this.targetCount,
      alarmSoundId: alarmSoundId ?? this.alarmSoundId,
      alarmVolume: alarmVolume ?? this.alarmVolume,
      customSoundPath: customSoundPath ?? this.customSoundPath,
      customSoundName: customSoundName ?? this.customSoundName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': alarmTime.hour,
      'minute': alarmTime.minute,
      'missionTypeId': missionTypeId,
      'isEnabled': isEnabled,
      'targetCount': targetCount,
      'alarmSoundId': alarmSoundId,
      'alarmVolume': alarmVolume,
      'customSoundPath': customSoundPath,
      'customSoundName': customSoundName,
    };
  }

  factory AlarmSettings.fromJson(Map<String, dynamic> json) {
    return AlarmSettings(
      alarmTime: TimeOfDay(hour: json['hour'], minute: json['minute']),
      missionTypeId: (json['missionTypeId'] as String?) ?? 'squat',
      isEnabled: json['isEnabled'] ?? true,
      targetCount: json['targetCount'],
      alarmSoundId: (json['alarmSoundId'] as String?) ?? 'fanfare',
      alarmVolume: (json['alarmVolume'] ?? 1.0).toDouble(),
      customSoundPath: json['customSoundPath'] as String?,
      customSoundName: json['customSoundName'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AlarmSettings.fromJsonString(String jsonString) {
    return AlarmSettings.fromJson(jsonDecode(jsonString));
  }

  static AlarmSettings get defaultSettings => AlarmSettings(
        alarmTime: const TimeOfDay(hour: 7, minute: 0),
        missionTypeId: 'squat',
      );
}
