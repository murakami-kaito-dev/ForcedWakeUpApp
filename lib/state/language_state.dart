import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';

class LanguageState extends ChangeNotifier {
  static const _key = 'app_language';

  final SharedPreferences _prefs;
  late String _locale;
  late bool _isFirstLaunch;

  LanguageState(this._prefs) {
    final saved = _prefs.getString(_key);
    _isFirstLaunch = saved == null;
    _locale = saved ?? 'ja';
  }

  String get locale => _locale;
  bool get isFirstLaunch => _isFirstLaunch;

  AppStrings get strings => _locale == 'en' ? AppStrings.en : AppStrings.ja;

  Future<void> setLanguage(String locale) async {
    _locale = locale;
    _isFirstLaunch = false;
    await _prefs.setString(_key, locale);
    notifyListeners();
  }
}
