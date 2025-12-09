import 'package:flutter/material.dart';
import 'package:health_care/theme/app_theme.dart';

// 📁 lib/widgets/pastel_card.dart - Reusable Pastel Cards

class PastelCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const PastelCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.borderRadius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.cardBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.textLight.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// Gradient Background Widget
class GradientBackground extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.colors,
    required this.child,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }
}

// Mood Option Selector Button
class MoodOptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodOptionButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.textDark 
              : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected 
                ? AppColors.textDark 
                : Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// Weekly Mood Circle Indicator
class WeeklyMoodCircle extends StatelessWidget {
  final String day;
  final int moodScore; // 1-10
  final bool isSelected;

  const WeeklyMoodCircle({
    super.key,
    required this.day,
    required this.moodScore,
    this.isSelected = false,
  });

  Color _getMoodColor() {
    if (moodScore >= 8) return AppColors.moodHappy;
    if (moodScore >= 6) return AppColors.moodCalm;
    if (moodScore >= 4) return AppColors.moodNeutral;
    if (moodScore >= 2) return AppColors.moodSad;
    return AppColors.moodAnxious;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getMoodColor(),
            border: isSelected 
                ? Border.all(color: AppColors.textDark, width: 2) 
                : null,
          ),
          child: Center(
            child: Text(
              moodScore.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.textDark : AppColors.textLight,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// Exercise Card Component
class ExerciseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final Color backgroundColor;
  final Widget? illustration;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.backgroundColor,
    this.illustration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (illustration != null) ...[
              illustration!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 14,
                  color: AppColors.textMedium,
                ),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Mood Tile for Daily Log
class MoodTile extends StatelessWidget {
  final String day;
  final Color color;
  final bool isToday;

  const MoodTile({
    super.key,
    required this.day,
    required this.color,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: isToday 
                ? Border.all(color: AppColors.textDark, width: 2) 
                : null,
          ),
          child: Center(
            child: Text(
              day.substring(0, 3),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: AppTextStyles.bodySmall.copyWith(
            color: isToday ? AppColors.textDark : AppColors.textLight,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// Stats Card
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget? icon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: 12),
            ],
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headlineLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
