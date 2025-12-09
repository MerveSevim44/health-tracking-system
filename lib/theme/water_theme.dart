// 🎨 Water Module Color Palette & Theme
// Now using unified app theme - re-exporting for compatibility

import 'package:flutter/material.dart';
import 'package:health_care/theme/app_theme.dart';

// Re-export AppColors as WaterColors for backward compatibility
class WaterColors {
  // Primary Water Blues
  static const Color waterPrimary = AppColors.waterPrimary;
  static const Color waterDark = AppColors.waterDark;
  static const Color waterLight = AppColors.waterLight;
  static const Color waterGradientStart = AppColors.waterBackground;
  static const Color waterGradientEnd = Color(0xFFFFFFFF);

  // Drink Type Colors (Pastel)
  static const Color drinkWater = AppColors.drinkWater;
  static const Color drinkCoffee = AppColors.drinkCoffee;
  static const Color drinkTea = AppColors.drinkTea;
  static const Color drinkMatcha = AppColors.drinkMatcha;
  static const Color drinkSoda = AppColors.drinkSoda;
  static const Color drinkWine = AppColors.drinkWine;
  static const Color drinkJuice = AppColors.drinkJuice;

  // UI Elements
  static const Color cardBackground = AppColors.cardBackground;
  static const Color glassBackground = Color(0x40FFFFFF);
  static const Color shadowColor = Color(0x1A000000);
  static const Color textDark = AppColors.textDark;
  static const Color textLight = AppColors.textLight;
  static const Color successGreen = Color(0xFF81C784);
  
  // Gradients
  static const LinearGradient waterBlobGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.waterPrimary,
      AppColors.waterDark,
    ],
  );

  static const LinearGradient screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.waterBackground,
      Color(0xFFFFFFFF),
    ],
  );
}

// Re-export AppTextStyles as WaterTextStyles
class WaterTextStyles {
  static const TextStyle displayLarge = AppTextStyles.displayLarge;
  static const TextStyle displayMedium = AppTextStyles.displayMedium;
  static const TextStyle headlineLarge = AppTextStyles.headlineLarge;
  static const TextStyle headlineMedium = AppTextStyles.headlineMedium;
  static const TextStyle bodyLarge = AppTextStyles.bodyLarge;
  static const TextStyle bodyMedium = AppTextStyles.bodyMedium;
  static const TextStyle labelLarge = AppTextStyles.labelLarge;
  static const TextStyle labelSmall = AppTextStyles.bodySmall;
}

class WaterShadows {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: WaterColors.shadowColor,
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: WaterColors.shadowColor,
      blurRadius: 15,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get button => [
    BoxShadow(
      color: WaterColors.waterPrimary.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
