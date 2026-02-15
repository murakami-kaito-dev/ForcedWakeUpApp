import 'package:flutter/material.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  final databaseService = DatabaseService();
  final statisticsService = StatisticsService(databaseService);
  final badgeService = BadgeService(databaseService);

  final subscriptionService = SubscriptionService();
  final premiumState = PremiumState(subscriptionService);
  await premiumState.initialize();

  final languageState = LanguageState(prefs);

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
