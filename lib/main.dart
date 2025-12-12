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
import 'package:health_care/screens/medication/medication_add_screen.dart';
import 'package:health_care/screens/settings_screen.dart'; // Yeni eklendi
import 'package:health_care/screens/help_center_screen.dart'; // Yeni eklendi
import 'package:health_care/screens/privacy_policy_screen.dart'; // Yeni eklendi


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
      case '/':
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

    // Özel Animasyonlu Geçişi (Soldan Kayma) uygula
    return PageRouteBuilder(
      settings: settings, // Rota ayarlarını korur
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Soldan sağa kayarak geçiş animasyonu ayarları
        const begin = Offset(1.0, 0.0); // Sağdan başla
        const end = Offset.zero;       // Sola kay
        const curve = Curves.ease;     // Yumuşak geçiş eğrisi

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracking System',
      debugShowCheckedModeBanner: false,
      theme: pastelAppTheme,

      // HOME YERİNE STREAMBUILDER KULLANILARAK OTURUM KONTROLÜ
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

          // 2. Durum: Kullanıcı giriş yapmış
          if (snapshot.hasData && snapshot.data != null) {
            return const PastelHomeNavigation();
          }

          // 3. Durum: Kullanıcı giriş yapmamışsa
          return const FirstScreen();
        },
      ),

      onGenerateRoute: _onGenerateRoute,
    );
  }
}
