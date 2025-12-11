import 'package:flutter/material.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:health_care/screens/daily_mood_home_screen.dart';
import 'package:health_care/screens/weekly_dashboard_screen.dart';
import 'package:health_care/screens/insights_screen.dart';
import 'package:health_care/screens/mood_selection_screen.dart';
import 'package:health_care/screens/water/water_home_screen.dart';
import 'package:health_care/screens/breathing_exercise_screen.dart';
import 'package:health_care/screens/medication/medication_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/water_model.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/models/mood_model.dart';

// GEREKLİ: AuthService importu
import '../services/auth_service.dart';
// 🔥 YENİ EKRAN İMPORTU: Artık ProfilePlaceholder yerine ProfileScreen kullanılıyor.
import 'profile_screen.dart';

// 📁 lib/screens/pastel_home_navigation.dart

class PastelHomeNavigation extends StatefulWidget {
  const PastelHomeNavigation({super.key});

  @override
  State<PastelHomeNavigation> createState() => _PastelHomeNavigationState();
}

class _PastelHomeNavigationState extends State<PastelHomeNavigation> {
  int _currentIndex = 0;
  String? _username; // Kullanıcı adını tutmak için değişken
  late Future<void> _initData;

  @override
  void initState() {
    super.initState();
    _initData = _initializeData();
  }

  Future<void> _initializeData() async {
    // Model başlatmaları
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaterModel>().initialize();
      context.read<MedicationModel>().initialize();
    });

    // Kullanıcı adını çek
    final username = await AuthService().fetchUsername();
    if (mounted) {
      setState(() {
        _username = username;
      });
    }
  }

  // 🔥 YÖNLENDİRME METODU: Kullanıcı adını alt widget'lara aktarır
  Widget _getScreen(int index) {
    // Tüm ekranlar dinamik olarak, _username verisi çekildikten sonra oluşturulur
    final List<Widget> screens = [
      DailyMoodHomeScreen(username: _username),  // Index 0: Kullanıcı adı aktarılıyor
      const WeeklyDashboardScreen(),
      const WaterHomeScreen(),
      const MedicationHomeScreen(),
      ProfileScreen(username: _username),       // Index 4: ProfileScreen'e aktarılıyor
    ];

    if (index >= 0 && index < screens.length) {
      return screens[index];
    }
    return const Center(child: Text("Hata: Geçersiz sayfa indeksi.", style: TextStyle(color: Colors.red)));
  }

  @override
  Widget build(BuildContext context) {
    // Veri yüklenirken veya kullanıcı adı çekilirken yükleniyor ekranı göster
    return FutureBuilder(
        future: _initData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Veri yüklendikten sonra normal navigasyon yapısını döndür
          return Scaffold(
            body: _getScreen(_currentIndex),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    // AppColors.textLight.withOpacity ile uyumlu olması beklenir
                    color: AppColors.textLight.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_outlined, 0),        // Home
                      _buildNavItem(Icons.bar_chart_outlined, 1),   // Dashboard
                      _buildNavItem(Icons.water_drop_outlined, 2),  // Water
                      _buildNavItem(Icons.medication_liquid, 3),    // Medication
                      _buildNavItem(Icons.person_outline, 4),       // Profile
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoodSelectionScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.moodHappy,
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
        }
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: isSelected ? AppColors.textDark : AppColors.textLight,
          size: 28,
        ),
      ),
    );
  }
}

// ⚠️ Not: ProfilePlaceholder sınıfı kaldırılmıştır. ProfileScreen widget'ı
// ayrı bir dosyada tanımlı olmalıdır.