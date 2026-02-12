import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/alarm_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/completion_screen.dart';

class ForcedWakeUpApp extends MaterialApp {
  ForcedWakeUpApp({super.key})
      : super(
          title: '朝型強制変換アラーム',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF533483),
            scaffoldBackgroundColor: const Color(0xFF1A1A2E),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF533483),
              secondary: Color(0xFF0F3460),
              surface: Color(0xFF16213E),
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/sleep': (context) => const SleepScreen(),
            '/alarm': (context) => const AlarmScreen(),
            '/exercise': (context) => const ExerciseScreen(),
            '/completion': (context) => const CompletionScreen(),
          },
        );
}
