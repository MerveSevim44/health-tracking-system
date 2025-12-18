import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:health_care/screens/daily_mood_home_screen.dart';
import 'package:health_care/screens/weekly_dashboard_screen.dart';
import 'package:health_care/screens/water/water_home_screen.dart';
import 'package:health_care/screens/medication/medication_home_screen.dart';
import 'package:health_care/screens/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/water_model.dart';
import 'package:health_care/models/medication_model.dart';

// GEREKLİ: AuthService importu
import '../services/auth_service.dart';
// 🔥 YENİ EKRAN İMPORTU: SettingsScreen kullanılıyor.
import 'settings_screen.dart';

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
      DailyMoodHomeScreen(
        username: _username,
      ), // Index 0: Kullanıcı adı aktarılıyor
      const WeeklyDashboardScreen(),
      const ChatScreen(), // Index 2: AI Coach Chat
      const WaterHomeScreen(),
      const MedicationHomeScreen(),
      const SettingsScreen(), // Index 5: Settings Screen
    ];

    if (index >= 0 && index < screens.length) {
      return screens[index];
    }
    return const Center(
      child: Text(
        "Hata: Geçersiz sayfa indeksi.",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Veri yüklenirken veya kullanıcı adı çekilirken yükleniyor ekranı göster
    return FutureBuilder(
      future: _initData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0E1220), // Consistent dark background
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Veri yüklendikten sonra normal navigasyon yapısını döndür
        return Scaffold(
          backgroundColor: const Color(0xFF0E1220), // Dark background to prevent white bleed
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Fade + Scale transition for modern smooth effect
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: _getScreen(_currentIndex),
            ),
          ),
          bottomNavigationBar: _buildModernNavBar(),
        );
      },
    );
  }

  // 🎨 Modern Glassmorphic Bottom Navigation Bar (Edge-to-Edge)
  Widget _buildModernNavBar() {
    return Container(
      width: double.infinity, // Force full width
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E1220), // Dark gradient start
            Color(0xFF1A1F3C), // Dark gradient end
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity, // Ensure inner container is also full width
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0E1220).withOpacity(0.95),
                  const Color(0xFF1A1F3C).withOpacity(0.95),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              left: false,  // Allow navbar to extend to left edge
              right: false, // Allow navbar to extend to right edge
              top: false,   // No top padding needed
              bottom: true, // Only respect bottom safe area (notch/home indicator)
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_rounded, 0),
                    _buildNavItem(Icons.bar_chart_rounded, 1),
                    _buildNavItem(Icons.psychology_rounded, 2),
                    _buildNavItem(Icons.water_drop_rounded, 3),
                    _buildNavItem(Icons.medication_rounded, 4),
                    _buildNavItem(Icons.person_rounded, 5),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🎨 Modern Navigation Item with Gradient & Glow
  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubicEmphasized,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.3),
                    const Color(0xFF00D4FF).withOpacity(0.2),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient effect
            AnimatedScale(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubicEmphasized,
              scale: isSelected ? 1.1 : 1.0,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  if (isSelected) {
                    return const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6C63FF),
                        Color(0xFF00D4FF),
                      ],
                    ).createShader(bounds);
                  }
                  return const LinearGradient(
                    colors: [Color(0xFF7A7FA8), Color(0xFF7A7FA8)],
                  ).createShader(bounds);
                },
                child: Icon(
                  icon,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Active indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubicEmphasized,
              margin: const EdgeInsets.only(top: 6),
              width: isSelected ? 6 : 0,
              height: isSelected ? 6 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6C63FF),
                    Color(0xFF00D4FF),
                  ],
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ⚠️ Not: ProfilePlaceholder sınıfı kaldırılmıştır. ProfileScreen widget'ı
// ayrı bir dosyada tanımlı olmalıdır.

