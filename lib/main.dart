import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'state/alarm_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AlarmState(storageService),
      child: ForcedWakeUpApp(),
    ),
  );
}
