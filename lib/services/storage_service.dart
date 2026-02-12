import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_settings.dart';

class StorageService {
  static const _key = 'alarm_settings';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveAlarmSettings(AlarmSettings settings) async {
    await _prefs.setString(_key, settings.toJsonString());
  }

  AlarmSettings? loadAlarmSettings() {
    final json = _prefs.getString(_key);
    if (json == null) return null;
    return AlarmSettings.fromJsonString(json);
  }
}
