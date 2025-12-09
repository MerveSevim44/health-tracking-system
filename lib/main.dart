import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:health_care/screens/breathing_exercise_screen.dart';
import 'package:health_care/screens/first_screen.dart';
import 'package:health_care/screens/pastel_home_navigation.dart';
import 'package:health_care/screens/water/water_home_screen.dart';
import 'package:health_care/screens/water/water_stats_screen.dart';
import 'package:health_care/screens/water/water_success_screen.dart';
import 'package:health_care/screens/medication/medication_home_screen.dart';
import 'package:health_care/screens/medication/medication_detail_screen.dart';
import 'package:health_care/screens/medication/medication_add_screen.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'models/mood_model.dart';
import 'models/water_model.dart';
import 'models/medication_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodModel()),
        ChangeNotifierProvider(create: (_) => WaterModel()),
        ChangeNotifierProvider(create: (_) => MedicationModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracking System',
      debugShowCheckedModeBanner: false,
      theme: pastelAppTheme,
      home: const FirstScreen(),
      routes: {
        '/home': (context) => const PastelHomeNavigation(),
        '/breathing': (context) => const BreathingExerciseScreen(),
        '/water/home': (context) => const WaterHomeScreen(),
        '/water/stats': (context) => const WaterStatsScreen(),
        '/water/success': (context) => const WaterSuccessScreen(
          achievedAmount: 2000,
          goalAmount: 2000,
        ),
        '/medication': (context) => const MedicationHomeScreen(),
        '/medication/detail': (context) => const MedicationDetailScreen(),
        '/medication/add': (context) => const MedicationAddScreen(),
      },
    );
  }
}