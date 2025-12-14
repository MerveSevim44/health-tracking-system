import 'package:flutter/material.dart';

// 📁 lib/theme/app_theme.dart - MINOA Theme System

// 🎨 UNIFIED COLOR PALETTE (Light & Dark Support)
class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFFFFD166);
  static const Color secondary = Color(0xFF06D6A0);
  static const Color accent = Color(0xFFFF6B9D);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFBFBFB);
  static const Color lightSurface = Colors.white;
  static const Color lightCardBg = Colors.white;
  static const Color lightTextPrimary = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);
  static const Color lightTextTertiary = Color(0xFFB2BEC3);
  static const Color lightBorder = Color(0xFFE8E8E8);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F0F1E);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCardBg = Color(0xFF252538);
  static const Color darkTextPrimary = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFB8B8D1);
  static const Color darkTextTertiary = Color(0xFF7A7A8E);
  static const Color darkBorder = Color(0xFF2A2A3E);
  
  // Mood Colors (Work in both themes)
  static const Color moodGreat = Color(0xFFFFD166);
  static const Color moodGood = Color(0xFF06D6A0);
  static const Color moodNeutral = Color(0xFFB8B8B8);
  static const Color moodBad = Color(0xFFFF9A76);
  static const Color moodAwful = Color(0xFFEF476F);
  
  // Emotion Colors
  static const Color emotionHappy = Color(0xFFFFD166);
  static const Color emotionCalm = Color(0xFF06D6A0);
  static const Color emotionSad = Color(0xFF118AB2);
  static const Color emotionAnxious = Color(0xFFEF476F);
  static const Color emotionAngry = Color(0xFFFF6B6B);
  static const Color emotionTired = Color(0xFF9D84B7);
  static const Color emotionEnergetic = Color(0xFFFF9A76);
  static const Color emotionExcited = Color(0xFFFF6B9D);
  
  // Water Tracking Colors
  static const Color waterPrimary = Color(0xFF4FC3F7);
  static const Color waterDark = Color(0xFF29B6F6);
  static const Color waterLight = Color(0xFFB3E5FC);
  static const Color waterBackground = Color(0xFFE1F5FE);
  
  // Functional Colors
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD166);
  static const Color error = Color(0xFFEF476F);
  static const Color info = Color(0xFF4FC3F7);
  
  // Convenience aliases for backward compatibility
  static const Color textLight = lightTextTertiary;
  static const Color textDark = lightTextPrimary;
  static const Color textMedium = lightTextSecondary;
  static const Color cardBackground = lightCardBg;
  
  // Mood color aliases
  static const Color moodHappy = emotionHappy;
  static const Color moodCalm = emotionCalm;
  static const Color moodSad = emotionSad;
  static const Color moodAnxious = emotionAnxious;
}

// � SPACING CONSTANTS
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

// 🔘 BORDER RADIUS CONSTANTS
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

// 🔤 TEXT STYLES (Theme-aware)
class AppTextStyles {
  static const String fontFamily = 'Inter';
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.3,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}

// 🌞 LIGHT THEME
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBackground,
  
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.accent,
    surface: AppColors.lightSurface,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.lightTextPrimary,
    onError: Colors.white,
    outline: AppColors.lightBorder,
  ),
  
  textTheme: const TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
  ).apply(
    bodyColor: AppColors.lightTextPrimary,
    displayColor: AppColors.lightTextPrimary,
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextPrimary,
    ),
    iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
  ),
  
  cardTheme: CardThemeData(
    color: AppColors.lightCardBg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.xl),
    ),
    shadowColor: AppColors.lightTextTertiary.withValues(alpha: 0.1),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.lightBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.lightBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  ),
  
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.lightSurface,
    selectedColor: AppColors.primary,
    labelStyle: const TextStyle(fontSize: 14),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
  ),
  
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.lightSurface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.lightTextTertiary,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);

// 🌙 DARK THEME
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.accent,
    surface: AppColors.darkSurface,
    error: AppColors.error,
    onPrimary: AppColors.darkTextPrimary,
    onSecondary: AppColors.darkTextPrimary,
    onSurface: AppColors.darkTextPrimary,
    onError: Colors.white,
    outline: AppColors.darkBorder,
  ),
  
  textTheme: const TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
  ).apply(
    bodyColor: AppColors.darkTextPrimary,
    displayColor: AppColors.darkTextPrimary,
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextPrimary,
    ),
    iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
  ),
  
  cardTheme: CardThemeData(
    color: AppColors.darkCardBg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.xl),
    ),
    shadowColor: Colors.black.withValues(alpha: 0.3),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkCardBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  ),
  
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.darkCardBg,
    selectedColor: AppColors.primary,
    labelStyle: const TextStyle(fontSize: 14),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
  ),
  
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSurface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.darkTextTertiary,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);

// 🎨 LEGACY SUPPORT (For backward compatibility)
ThemeData pastelAppTheme = lightTheme;


