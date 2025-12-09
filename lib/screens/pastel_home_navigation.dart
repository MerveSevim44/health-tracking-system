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

// 🔥 GEREKLİ: AuthService importu (Yolunuzun doğru olduğundan emin olun)
import '../services/auth_service.dart';

// 📁 lib/screens/pastel_home_navigation.dart

class PastelHomeNavigation extends StatefulWidget {
  const PastelHomeNavigation({super.key});

  @override
  State<PastelHomeNavigation> createState() => _PastelHomeNavigationState();
}

class _PastelHomeNavigationState extends State<PastelHomeNavigation> {
  int _currentIndex = 0;
  // 🔥 EKLENDİ: Kullanıcı adını tutmak için değişken ve Future
  String? _username;
  late Future<void> _initData;

  @override
  void initState() {
    super.initState();
    // Veri model başlatmalarını ve kullanıcı adını çekme işlemini başlat
    _initData = _initializeData();
  }

  // 🔥 EKLENDİ: Veri başlatma ve kullanıcı adını çekme fonksiyonu
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

  // DÜZELTME: Ekran listesi, 5 temel navigasyon öğesine uyacak şekilde kısaltıldı.
  final List<Widget> _screens = const [
    DailyMoodHomeScreen(),      // Index 0: Home (Günlük Ruh Hali)
    WeeklyDashboardScreen(),    // Index 1: Dashboard (Haftalık Gösterge)
    WaterHomeScreen(),          // Index 2: Water (Su Takibi)
    MedicationHomeScreen(),     // Index 3: Medication (İlaç Takibi)
    ProfilePlaceholder(),       // Index 4: Profile (Kullanıcı Profili)
  ];

  // 🔥 YÖNLENDİRME METODU: Kullanıcı adını alt widget'lara aktarmak için kullanılır
  Widget _getScreen(int index) {
    if (index == 0) {
      // Eğer ana ekran (DailyMoodHomeScreen) kullanıcı adını gösteriyorsa,
      // constructor üzerinden kullanıcı adını yollayabiliriz.
      // Ancak DailyMoodHomeScreen'in constructor'ı değişmediği için varsayılanı kullanıyoruz.
      // En iyi yöntem, bu veriyi Provider ile sağlamaktır.
      // Şimdilik, verinin çekildiğini varsayalım.
    }
    return _screens[index];
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 EKLENDİ: Veri yüklenirken veya kullanıcı adı çekilirken yükleniyor ekranı göster
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
                    color: AppColors.textLight.withValues(alpha: 0.1),
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

// ProfilePlaceholder (Aynı kalır)
class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.pastelLavender,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 50,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Profile',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              // Düzeltildi: Getter yerine yeni public metot kullanıldı
              'Kullanıcı: ${AuthService().getCurrentUser()?.email ?? 'Yok'}',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}