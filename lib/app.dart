import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/alarm_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/completion_screen.dart';
import 'screens/failure_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/sound_selection_screen.dart';
import 'services/statistics_service.dart';
import 'state/language_state.dart';

class ForcedWakeUpApp extends StatelessWidget {
  const ForcedWakeUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final statisticsService = context.read<StatisticsService>();
    final s = context.watch<LanguageState>().strings;

    return MaterialApp(
      title: s.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.accent,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          secondary: AppColors.selected,
          surface: AppColors.surface,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/sleep': (context) => const SleepScreen(),
        '/alarm': (context) =>
            AlarmScreen(statisticsService: statisticsService),
        '/exercise': (context) => const ExerciseScreen(),
        '/completion': (context) =>
            CompletionScreen(statisticsService: statisticsService),
        '/failure': (context) =>
            FailureScreen(statisticsService: statisticsService),
        '/paywall': (context) => const PaywallScreen(),
        '/statistics': (context) =>
            StatisticsScreen(statisticsService: statisticsService),
        '/sound-selection': (context) => const SoundSelectionScreen(),
      },
    );
  }
}
