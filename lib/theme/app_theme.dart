import 'package:flutter/material.dart';

// 📁 lib/theme/app_theme.dart - Pastel Mood Tracking Theme

// 🎨 PASTEL COLOR PALETTE
class AppColors {
  // Primary Pastels
  static const Color pastelYellow = Color(0xFFFFF9E6);
  static const Color pastelMint = Color(0xFFE8F5E3);
  static const Color pastelLavender = Color(0xFFF3EFFF);
  static const Color pastelPink = Color(0xFFFFE8F0);
  static const Color pastelPeach = Color(0xFFFFECDB);
  static const Color pastelBlue = Color(0xFFE3F2FD);
  
  // Mood Colors (Soft versions)
  static const Color moodHappy = Color(0xFFFFD166);
  static const Color moodCalm = Color(0xFF06D6A0);
  static const Color moodSad = Color(0xFF118AB2);
  static const Color moodAnxious = Color(0xFFEF476F);
  static const Color moodAngry = Color(0xFFFF6B6B);
  static const Color moodNeutral = Color(0xFFB8B8B8);
  
  // Water Tracking Colors
  static const Color waterPrimary = Color(0xFF4FC3F7);
  static const Color waterDark = Color(0xFF29B6F6);
  static const Color waterLight = Color(0xFFB3E5FC);
  static const Color waterBackground = Color(0xFFE1F5FE);
  
  // Drink Type Colors (Pastel)
  static const Color drinkWater = Color(0xFF4FC3F7);
  static const Color drinkCoffee = Color(0xFFFFCC80);
  static const Color drinkTea = Color(0xFFCE93D8);
  static const Color drinkMatcha = Color(0xFFA5D6A7);
  static const Color drinkSoda = Color(0xFFEF9A9A);
  static const Color drinkWine = Color(0xFFE1BEE7);
  static const Color drinkJuice = Color(0xFFFFF59D);
  
  // Gradient Colors
  static const Color gradientYellowStart = Color(0xFFFFF4CC);
  static const Color gradientYellowEnd = Color(0xFFFFE8A3);
  static const Color gradientMintStart = Color(0xFFD4F1E8);
  static const Color gradientMintEnd = Color(0xFFB8E6D5);
  static const Color gradientLavenderStart = Color(0xFFE8DEFF);
  static const Color gradientLavenderEnd = Color(0xFFD4C5F9);
  
  // Text Colors
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMedium = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);
  
  // Background
  static const Color background = Color(0xFFFBFBFB);
  static const Color cardBackground = Colors.white;
}

// 🔤 TEXT STYLES (Thin, friendly typography)
class AppTextStyles {
  static const String fontFamily = 'Inter'; // Use Inter or SF Pro Display
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
}

// 🎨 MAIN THEME
ThemeData pastelAppTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  
  colorScheme: const ColorScheme.light(
    primary: AppColors.moodHappy,
    secondary: AppColors.moodCalm,
    surface: AppColors.cardBackground,
    error: AppColors.moodAnxious,
    onPrimary: AppColors.textDark,
    onSecondary: Colors.white,
    onSurface: AppColors.textDark,
  ),
  
  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.textDark,
    ),
    iconTheme: IconThemeData(color: AppColors.textDark),
  ),
  
  // Card Theme
  cardTheme: CardThemeData(
    color: AppColors.cardBackground,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    shadowColor: AppColors.textLight.withValues(alpha: 0.1),
  ),
  
  // Bottom Navigation
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.textDark,
    unselectedItemColor: AppColors.textLight,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: true,
    showUnselectedLabels: false,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  ),
  
  // Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),
  
  // Text Theme
  textTheme: const TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
  ),
);
