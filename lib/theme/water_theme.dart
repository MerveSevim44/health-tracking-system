// 🎨 Water Module - Modern Dark Theme
import 'package:flutter/material.dart';
import 'package:health_care/theme/modern_colors.dart';

class WaterColors {
  // Primary Water Colors - Modern Dark Theme
  static const Color waterPrimary = ModernAppColors.vibrantCyan;
  static const Color waterDark = ModernAppColors.electricBlue;
  static const Color waterLight = ModernAppColors.vibrantCyan;
  static const Color waterGradientStart = ModernAppColors.darkBg;
  static const Color waterGradientEnd = ModernAppColors.cardBg;

  // Drink Type Colors (Vibrant Modern)
  static const Color drinkWater = ModernAppColors.vibrantCyan;
  static const Color drinkCoffee = Color(0xFF8D6E63);
  static const Color drinkTea = ModernAppColors.accentGreen;
  static const Color drinkMatcha = Color(0xFF9CCC65);
  static const Color drinkSoda = ModernAppColors.accentPink;
  static const Color drinkWine = Color(0xFFAB47BC);
  static const Color drinkJuice = ModernAppColors.accentOrange;

  // UI Elements
  static const Color cardBackground = ModernAppColors.cardBg;
  static const Color glassBackground = Color(0x40FFFFFF);
  static const Color shadowColor = Color(0x4A000000);
  static const Color textDark = ModernAppColors.lightText;
  static const Color textLight = ModernAppColors.mutedText;
  static const Color successGreen = ModernAppColors.accentGreen;
  
  // Gradients
  static const LinearGradient waterBlobGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      ModernAppColors.vibrantCyan,
      ModernAppColors.electricBlue,
    ],
  );

  static const LinearGradient screenGradient = ModernAppColors.backgroundGradient;
}

class WaterTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: ModernAppColors.lightText,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: ModernAppColors.lightText,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: ModernAppColors.lightText,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: ModernAppColors.lightText,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: ModernAppColors.lightText,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: ModernAppColors.mutedText,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ModernAppColors.lightText,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    color: ModernAppColors.mutedText,
  );
}

class WaterShadows {
  static List<BoxShadow> get soft => [
    ModernAppColors.cardShadow(opacity: 0.2),
  ];

  static List<BoxShadow> get card => [
    ModernAppColors.cardShadow(opacity: 0.15),
  ];

  static List<BoxShadow> get button => [
    BoxShadow(
      color: ModernAppColors.vibrantCyan.withOpacity(0.4),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
}
