import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/badge_service.dart';
import 'services/database_service.dart';
import 'services/statistics_service.dart';
import 'services/storage_service.dart';
import 'services/subscription_service.dart';
import 'state/alarm_state.dart';
import 'state/language_state.dart';
import 'state/premium_state.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  final databaseService = DatabaseService();
  final statisticsService = StatisticsService(databaseService);
  final badgeService = BadgeService(databaseService);

  final subscriptionService = SubscriptionService();
  final premiumState = PremiumState(subscriptionService);
  await premiumState.initialize();

  final languageState = LanguageState(prefs);

  // --- スプラッシュ表示時間（秒数を変更して調整） ---
  await Future.delayed(const Duration(milliseconds: 500));
  FlutterNativeSplash.remove();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmState(storageService)),
        ChangeNotifierProvider.value(value: premiumState),
        ChangeNotifierProvider.value(value: languageState),
        ChangeNotifierProvider.value(value: badgeService),
        Provider.value(value: statisticsService),
      ],
      child: const ForcedWakeUpApp(),
    ),
  );
}
