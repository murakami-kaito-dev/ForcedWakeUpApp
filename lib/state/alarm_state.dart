import 'package:flutter/material.dart';
import '../models/alarm_settings.dart';
import '../models/exercise_type.dart';
import '../services/storage_service.dart';

class AlarmState extends ChangeNotifier {
  final StorageService _storageService;

  AlarmSettings _settings;
  bool _isAlarmRinging = false;
  int _completedReps = 0;
  static const int targetReps = 10;

  AlarmState(this._storageService)
      : _settings = _storageService.loadAlarmSettings() ??
            AlarmSettings.defaultSettings;

  AlarmSettings get settings => _settings;
  bool get isAlarmRinging => _isAlarmRinging;
  int get completedReps => _completedReps;
  int get remainingReps => targetReps - _completedReps;
  bool get isExerciseComplete => _completedReps >= targetReps;

  Future<void> updateAlarmTime(TimeOfDay time) async {
    _settings = _settings.copyWith(alarmTime: time);
    await _storageService.saveAlarmSettings(_settings);
    notifyListeners();
  }

  Future<void> updateExerciseType(ExerciseType type) async {
    _settings = _settings.copyWith(exerciseType: type);
    await _storageService.saveAlarmSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleEnabled(bool enabled) async {
    _settings = _settings.copyWith(isEnabled: enabled);
    await _storageService.saveAlarmSettings(_settings);
    notifyListeners();
  }

  void triggerAlarm() {
    _isAlarmRinging = true;
    _completedReps = 0;
    notifyListeners();
  }

  void incrementRep() {
    _completedReps++;
    notifyListeners();
  }

  void updateReps(int reps) {
    _completedReps = reps;
    notifyListeners();
  }

  void resetAlarm() {
    _isAlarmRinging = false;
    _completedReps = 0;
    notifyListeners();
  }
}
