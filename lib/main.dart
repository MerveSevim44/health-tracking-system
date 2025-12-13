import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// 🔥 GEREKLİ: Firebase Auth durumu kontrolü için
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
import 'package:health_care/utils/page_transitions.dart';

// ------------------------------------
// EKRAN IMPORTS
// ------------------------------------
import 'package:health_care/screens/splash_screen.dart'; // 🔥 SPLASH SCREEN
import 'package:health_care/screens/landing_page.dart'; // 🔥 NEW MODERN LANDING PAGE
import 'package:health_care/screens/first_screen.dart'; // 🔥 GİRİŞ YAPILMADIYSA GÖRÜNÜR
import 'package:health_care/screens/login_screen.dart';
import 'package:health_care/screens/register_screen.dart';
import 'package:health_care/screens/auth_wrapper.dart'; // 🔥 Login sonrası mood kontrolü
import 'package:health_care/screens/pastel_home_navigation.dart'; // 🔥 GİRİŞ YAPILDIYSA GÖRÜNÜR
import 'package:health_care/screens/breathing_exercise_screen.dart';
import 'package:health_care/screens/water/water_home_screen.dart';
import 'package:health_care/screens/water/water_stats_screen.dart';
import 'package:health_care/screens/water/water_success_screen.dart';
import 'package:health_care/screens/medication/medication_home_screen.dart';
import 'package:health_care/screens/medication/medication_detail_screen.dart';
import 'package:health_care/screens/medication/medication_add_screen.dart';
import 'package:health_care/screens/settings_screen.dart'; // Yeni eklendi
import 'package:health_care/screens/help_center_screen.dart'; // Yeni eklendi
import 'package:health_care/screens/privacy_policy_screen.dart'; // Yeni eklendi


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

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
        ChangeNotifierProvider(create: (_) => DrinkProvider()..initialize()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Animasyonlu sayfa geçişini oluşturan ana fonksiyon (onGenerateRoute)
  Route<dynamic> _onGenerateRoute(RouteSettings settings) {

    // Rota adına göre hedef sayfayı belirle
    final Widget page;
    switch (settings.name) {
    // AUTH ROTALARI
      case '/splash':
        page = const SplashScreen(); // 🔥 SPLASH SCREEN
        break;
      case '/':
      case '/landing':
        page = const LandingPage(); // 🔥 NEW MODERN LANDING PAGE
        break;
      case '/first':
        page = const FirstScreen();
        break;
      case '/login':
        page = const LoginScreen();
        break;
      case '/register':
        page = const RegisterScreen();
        break;

    // ANA ROTA VE ÖZELLİK ROTALARI
      case '/home':
        page = const PastelHomeNavigation();
        break;
      case '/breathing':
        page = const BreathingExerciseScreen();
        break;

    // Su Takibi Rotaları
      case '/water/home':
        page = const WaterHomeScreen();
        break;
      case '/water/stats':
        page = const WaterStatsScreen();
        break;
      case '/water/success':
      // 🔥 DÜZELTME: WaterSuccessScreen'in parametreleri artık dinamik olarak (argümanlardan) alınabilir.
      // Eğer argüman yoksa, varsayılan 2000 değeri kullanılır.
        final args = settings.arguments as Map<String, int>?;
        final achievedAmount = args?['achievedAmount'] ?? 2000;
        final goalAmount = args?['goalAmount'] ?? 2000;

        page = WaterSuccessScreen(
          achievedAmount: achievedAmount,
          goalAmount: goalAmount,
        );
        break;

    // İlaç Takibi Rotaları
      case '/medication':
        page = const MedicationHomeScreen();
        break;
      case '/medication/detail':
        page = const MedicationDetailScreen();
        break;
      case '/medication/add':
        page = const MedicationAddScreen();
        break;

    // Settings Routes (Yeni eklendi)
      case '/settings':
        page = const SettingsScreen();
        break;
      case '/help':
        page = const HelpCenterScreen();
        break;
      case '/privacy':
        page = const PrivacyPolicyScreen();
        break;

      default:
      // Tanımlanmamış rotalar için hata ekranı veya ana sayfa
        return MaterialPageRoute(builder: (_) => const FirstScreen());
    }

    // Rota tipine göre farklı animasyonlar uygula
    switch (settings.name) {
      // Splash screen için fade geçiş
      case '/':
      case '/splash':
        return PageTransitions.fadeTransition(page, settings: settings);
      
      // Landing page için özel fade geçiş
      case '/landing':
        return PageTransitions.fadeTransition(page, settings: settings);
      
      case '/first':
        return PageTransitions.fadeTransition(page, settings: settings);
      
      // Login/Register için yumuşak fade+slide
      case '/login':
      case '/register':
        return PageTransitions.fadeSlideTransition(page, settings: settings);
      
      // Home'a geçişte etkileyici scale+fade
      case '/home':
        return PageTransitions.zoomTransition(page, settings: settings);
      
      // Breathing egzersizi için zoom geçiş
      case '/breathing':
        return PageTransitions.zoomTransition(page, settings: settings);
      
      // Water success için scale geçiş
      case '/water/success':
        return PageTransitions.scaleTransition(page, settings: settings);
      
      // Diğer tüm sayfalar için yumuşak material geçiş
      default:
        return PageTransitions.materialTransition(page, settings: settings);
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracking System',
      debugShowCheckedModeBanner: false,
      theme: pastelAppTheme,

      // Always show splash screen first
      home: const SplashScreen(),

      onGenerateRoute: _onGenerateRoute,
    );
  }
}
