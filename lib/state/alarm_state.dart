import 'package:flutter/material.dart';
import '../models/alarm_settings.dart';
import '../models/mission_type.dart';
import '../services/storage_service.dart';

class AlarmState extends ChangeNotifier {
  final StorageService _storageService;

  AlarmSettings _settings;
  bool _isAlarmRinging = false;
  int _completedCount = 0;
  DateTime? _alarmTriggeredAt;

  AlarmState(this._storageService)
      : _settings = _storageService.loadAlarmSettings() ??
            AlarmSettings.defaultSettings;

  AlarmSettings get settings => _settings;
  bool get isAlarmRinging => _isAlarmRinging;
  int get completedCount => _completedCount;
  int get targetCount => _settings.targetCount;
  int get remainingCount => targetCount - _completedCount;
  bool get isMissionComplete => _completedCount >= targetCount;
  MissionType get missionType => _settings.missionType;
  DateTime? get alarmTriggeredAt => _alarmTriggeredAt;

  Future<void> updateAlarmTime(TimeOfDay time) async {
    _settings = _settings.copyWith(alarmTime: time);
    await _storageService.saveAlarmSettings(_settings);
    notifyListeners();
  }

  Future<void> updateMissionType(String missionTypeId) async {
    final mission = MissionType.fromId(missionTypeId);
    _settings = _settings.copyWith(
      missionTypeId: missionTypeId,
      targetCount: mission.defaultTarget,
    );
    await _storageService.saveAlarmSettings(_settings);
    notifyListeners();
  }

  Future<void> updateTargetCount(int count) async {
    _settings = _settings.copyWith(targetCount: count);
    await _storageService.saveAlarmSettings(_settings);
    notifyListeners();
  }

  Future<void> updateAlarmSound(String soundId) async {
    _settings = _settings.copyWith(alarmSoundId: soundId);
    await _storageService.saveAlarmSettings(_settings);
    notifyListeners();
  }

  Future<void> updateCustomSound(String? path, {String? name}) async {
    _settings = _settings.copyWith(
      alarmSoundId: path != null ? 'custom' : 'fanfare',
      customSoundPath: path,
      customSoundName: name,
    );
    await _storageService.saveAlarmSettings(_settings);
    notifyListeners();
  }

  Future<void> updateAlarmVolume(double volume) async {
    _settings = _settings.copyWith(alarmVolume: volume.clamp(0.3, 1.0));
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
    _completedCount = 0;
    _alarmTriggeredAt = DateTime.now();
    notifyListeners();
  }

  void updateCount(int count) {
    _completedCount = count;
    notifyListeners();
  }

  void resetAlarm() {
    _isAlarmRinging = false;
    _completedCount = 0;
    _alarmTriggeredAt = null;
    notifyListeners();
  }
}
