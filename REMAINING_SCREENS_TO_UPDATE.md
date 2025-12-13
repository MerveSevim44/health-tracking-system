# 🔄 Remaining Screens to Update

## Screens Still Using Old Theme:

### Priority 1 - User-Facing Screens
1. ✅ **mood_selection_screen.dart** - Uses AppColors, needs dark theme
2. ✅ **mood_checkin_screen.dart** - Uses AppColors, needs dark theme  
3. ✅ **profile_screen.dart** - Needs dark theme update
4. ✅ **edit_profile_screen.dart** - Needs dark theme
5. ✅ **breathing_exercise_screen.dart** - Needs dark theme
6. ✅ **insights_screen.dart** - Needs dark theme

### Priority 2 - Utility Screens
7. ✅ **help_center_screen.dart** - Needs dark theme
8. ✅ **privacy_policy_screen.dart** - Needs dark theme
9. ✅ **first_screen.dart** - Welcome screen (should redirect to landing)
10. ✅ **home_screen.dart** - Check if used or replaced by daily_mood_home_screen
11. ✅ **auth_wrapper.dart** - Check if needs updates

### Water Screens (Should auto-theme)
- water_home_screen.dart - Uses WaterTheme
- water_stats_screen.dart - Uses WaterTheme
- water_success_screen.dart - Uses WaterTheme
- drink_info_page.dart - Uses WaterTheme

### Medication Detail Screens
- medication_detail_enhanced_screen.dart - Check if needs update
- medication_detail_screen.dart - Check if used

## Update Pattern for Each Screen:

```dart
// 1. Import modern theme
import 'package:health_care/theme/modern_colors.dart';

// 2. Add animation controller
late AnimationController _floatController;

// 3. Initialize in initState
_floatController = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 3),
)..repeat(reverse: true);

// 4. Replace Scaffold
Scaffold(
  backgroundColor: ModernAppColors.darkBg,
  body: Stack(
    children: [
      _buildAnimatedBackground(),
      // content
    ],
  ),
)

// 5. Update all color references
AppColors.textDark → ModernAppColors.lightText
AppColors.textLight → ModernAppColors.mutedText
AppColors.background → ModernAppColors.darkBg
AppColors.cardBackground → ModernAppColors.cardBg

// 6. Update buttons to use gradients
Container(
  decoration: BoxDecoration(
    gradient: ModernAppColors.primaryGradient,
    borderRadius: BorderRadius.circular(20),
  ),
  child: ElevatedButton(...)
)
```

## I'll batch update these now...

