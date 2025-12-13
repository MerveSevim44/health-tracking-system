import 'package:flutter/material.dart';
import 'package:health_care/screens/daily_mood_home_screen.dart';
import 'package:health_care/screens/weekly_dashboard_screen.dart';
import 'package:health_care/screens/water/water_home_screen.dart';
import 'package:health_care/screens/medication/medication_home_screen.dart';
import 'package:health_care/screens/chat_screen.dart';
import 'package:health_care/screens/settings_screen.dart';
import 'package:health_care/theme/modern_colors.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/water_model.dart';
import 'package:health_care/models/medication_model.dart';
import '../services/auth_service.dart';
import 'dart:ui';

class PastelHomeNavigation extends StatefulWidget {
  const PastelHomeNavigation({super.key});

  @override
  State<PastelHomeNavigation> createState() => _PastelHomeNavigationState();
}

class _PastelHomeNavigationState extends State<PastelHomeNavigation> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String? _username;
  late Future<void> _initData;

  @override
  void initState() {
    super.initState();
    _initData = _initializeData();
  }

  Future<void> _initializeData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaterModel>().initialize();
      context.read<MedicationModel>().initialize();
    });

    final username = await AuthService().fetchUsername();
    if (mounted) {
      setState(() {
        _username = username;
      });
    }
  }

  Widget _getScreen(int index) {
    final List<Widget> screens = [
      DailyMoodHomeScreen(username: _username),
      const WeeklyDashboardScreen(),
      const ChatScreen(),
      const WaterHomeScreen(),
      const MedicationHomeScreen(),
      const SettingsScreen(),
    ];

    if (index >= 0 && index < screens.length) {
      return screens[index];
    }
    return const Center(
      child: Text(
        "Error: Invalid page",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: ModernAppColors.darkBg,
            body: Center(
              child: CircularProgressIndicator(
                color: ModernAppColors.vibrantCyan,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: ModernAppColors.darkBg,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
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

  Widget _buildModernNavBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 85,
          decoration: BoxDecoration(
            color: ModernAppColors.navbarBg.withOpacity(0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border(
              top: BorderSide(
                color: ModernAppColors.deepPurple.withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_rounded, 'Home', 0),
                  _buildNavItem(Icons.bar_chart_rounded, 'Stats', 1),
                  _buildNavItem(Icons.psychology_rounded, 'AI', 2),
                  _buildNavItem(Icons.water_drop_rounded, 'Water', 3),
                  _buildNavItem(Icons.medication_rounded, 'Meds', 4),
                  _buildNavItem(Icons.person_rounded, 'Profile', 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Haptic feedback would go here if available
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? ModernAppColors.primaryGradient
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ModernAppColors.deepPurple.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              scale: isSelected ? 1.1 : 1.0,
              child: Icon(
                icon,
                color: isSelected
                    ? ModernAppColors.lightText
                    : ModernAppColors.mutedText,
                size: 26,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: ModernAppColors.lightText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
