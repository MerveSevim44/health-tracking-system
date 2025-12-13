/// 🎨 Modern App-Wide Color Palette
/// Consistent colors used across all screens
/// Based on the redesigned Login, Register, and Landing pages

import 'package:flutter/material.dart';

class ModernAppColors {
  // Primary gradient colors
  static const deepPurple = Color(0xFF6C63FF);
  static const deepIndigo = Color(0xFF4834DF);
  static const vibrantCyan = Color(0xFF00D4FF);
  static const electricBlue = Color(0xFF0984E3);
  
  // Backgrounds
  static const darkBg = Color(0xFF0F0F1E);
  static const cardBg = Color(0xFF1A1A2E);
  static const navbarBg = Color(0xFF16162A);
  
  // Text colors
  static const lightText = Color(0xFFFFFFFF);
  static const mutedText = Color(0xFFB8B8D1);
  static const darkText = Color(0xFF8E8EA9);
  
  // Accent colors
  static const accentPink = Color(0xFFFF6B9D);
  static const accentOrange = Color(0xFFFF9F43);
  static const accentGreen = Color(0xFF00D9A3);
  static const accentYellow = Color(0xFFFECA57);
  
  // Status colors
  static const success = Color(0xFF00D9A3);
  static const warning = Color(0xFFFF9F43);
  static const error = Color(0xFFFF6B9D);
  static const info = Color(0xFF00D4FF);
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [deepPurple, vibrantCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const secondaryGradient = LinearGradient(
    colors: [accentGreen, vibrantCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      darkBg,
      Color(0xFF1A1A2E),
      darkBg,
    ],
  );
  
  // Shadows
  static BoxShadow primaryShadow({double opacity = 0.5}) {
    return BoxShadow(
      color: deepPurple.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 10),
    );
  }
  
  static BoxShadow cardShadow({double opacity = 0.1}) {
    return BoxShadow(
      color: Colors.black.withOpacity(opacity),
      blurRadius: 15,
      offset: const Offset(0, 5),
    );
  }
}


