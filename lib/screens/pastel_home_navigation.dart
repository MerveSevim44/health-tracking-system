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

// 📁 lib/screens/pastel_home_navigation.dart

class PastelHomeNavigation extends StatefulWidget {
  const PastelHomeNavigation({super.key});

  @override
  State<PastelHomeNavigation> createState() => _PastelHomeNavigationState();
}

class _PastelHomeNavigationState extends State<PastelHomeNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase listeners after user is authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaterModel>().initialize();
      context.read<MedicationModel>().initialize();
      // MoodModel doesn't need initialize (loads on demand)
    });
  }

  final List<Widget> _screens = const [
    DailyMoodHomeScreen(),
    WeeklyDashboardScreen(),
    WaterHomeScreen(),
    MedicationHomeScreen(),
    BreathingExerciseScreen(),
    InsightsScreen(),
    ProfilePlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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
                _buildNavItem(Icons.home_outlined, 0),
                _buildNavItem(Icons.bar_chart_outlined, 1),
                _buildNavItem(Icons.water_drop_outlined, 2),
                _buildNavItem(Icons.medication_liquid, 3),
                _buildNavItem(Icons.self_improvement, 4),
                _buildNavItem(Icons.chat_bubble_outline, 5),
                _buildNavItem(Icons.person_outline, 6),
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

// Placeholder for Profile Screen
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
              'Coming soon...',
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
