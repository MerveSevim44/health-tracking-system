import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// 🔥 GEREKLİ: Firebase Auth durumu kontrolü için
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

// ------------------------------------
// MODEL/STATE MANAGEMENT IMPORTS
// ------------------------------------
import 'models/mood_model.dart';
import 'models/water_model.dart';
import 'models/medication_model.dart';
import 'providers/drink_provider.dart';

// ------------------------------------
// TEMA VE DİĞER WIDGET IMPORTS
// ------------------------------------
import 'package:health_care/theme/app_theme.dart';

// ------------------------------------
// EKRAN IMPORTS
// ------------------------------------
import 'package:health_care/screens/first_screen.dart'; // 🔥 GİRİŞ YAPILMADIYSA GÖRÜNÜR
import 'package:health_care/screens/login_screen.dart';
import 'package:health_care/screens/register_screen.dart';
import 'package:health_care/screens/pastel_home_navigation.dart'; // 🔥 GİRİŞ YAPILDIYSA GÖRÜNÜR
import 'package:health_care/screens/breathing_exercise_screen.dart';
import 'package:health_care/screens/water/water_home_screen.dart';
import 'package:health_care/screens/water/water_stats_screen.dart';
import 'package:health_care/screens/water/water_success_screen.dart';
import 'package:health_care/screens/medication/medication_home_screen.dart';
import 'package:health_care/screens/medication/medication_detail_screen.dart';
import 'package:health_care/screens/medication/medication_add_enhanced_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlatma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodModel()),
        ChangeNotifierProvider(create: (_) => WaterModel()),
        ChangeNotifierProvider(create: (_) => MedicationModel()),
        ChangeNotifierProvider(
          create: (_) => DrinkProvider()..initialize(),
        ),
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

      // 🔥 HOME YERİNE STREAMBUILDER KULLANILARAK OTURUM KONTROLÜ
      home: StreamBuilder<User?>(
        // Firebase Auth'taki oturum değişikliklerini dinler
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Durum: Bağlantı bekleniyor (Yükleniyor ekranı)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. Durum: Kullanıcı giriş yapmış (snapshot.data bir kullanıcı içeriyorsa)
          if (snapshot.hasData && snapshot.data != null) {
            // Ana sayfaya (PastelHomeNavigation) yönlendir
            return const PastelHomeNavigation();
          }

          // 3. Durum: Kullanıcı giriş yapmamışsa
          // FirstScreen (Giriş/Kayıt) ekranını göster
          return const FirstScreen();
        },
      ),

      // Rotalar tanımlaması (Burada tanımlı kalmalıdır, yönlendirme butonu için kullanılır)
      routes: {
        // AUTH ROTALARI
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // ANA ROTA VE ÖZELLİK ROTALARI
        '/home': (context) => const PastelHomeNavigation(),
        '/breathing': (context) => const BreathingExerciseScreen(),

        // Su Takibi Rotaları
        '/water/home': (context) => const WaterHomeScreen(),
        '/water/stats': (context) => const WaterStatsScreen(),
        '/water/success': (context) => const WaterSuccessScreen(
          achievedAmount: 2000,
          goalAmount: 2000,
        ),

        // İlaç Takibi Rotaları
        '/medication': (context) => const MedicationHomeScreen(),
        '/medication/detail': (context) => const MedicationDetailScreen(),
        '/medication/add': (context) => const MedicationAddEnhancedScreen(),
      },
    );
  }
}