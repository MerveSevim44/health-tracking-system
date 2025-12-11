// 🏷️ Selected Drink Name Display Widget
// Seçilen içecek adını göstermek için şık ve animasyonlu widget

import 'package:flutter/material.dart';
import 'package:health_care/theme/water_theme.dart';
import 'package:health_care/widgets/water/drink_selector.dart';

/// Seçili içecek adını gösteren animasyonlu widget
class SelectedDrinkDisplay extends StatelessWidget {
  final DrinkType drinkType;
  final VoidCallback? onTap;

  const SelectedDrinkDisplay({
    super.key,
    required this.drinkType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              drinkType.color.withValues(alpha: 0.2),
              drinkType.color.withValues(alpha: 0.1),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: drinkType.color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: drinkType.color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // İçecek ikonu
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: drinkType.color.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                drinkType.icon,
                color: drinkType.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            
            // İçecek adı
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selected Drink',
                  style: WaterTextStyles.labelSmall.copyWith(
                    color: WaterColors.textLight,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  drinkType.name,
                  style: WaterTextStyles.labelLarge.copyWith(
                    color: WaterColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 8),
            
            // Info ikonu (opsiyonel)
            if (onTap != null)
              Icon(
                Icons.info_outline,
                color: drinkType.color,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

/// Daha kompakt versiyon - sadece isim ve ikon
class CompactDrinkDisplay extends StatelessWidget {
  final DrinkType drinkType;

  const CompactDrinkDisplay({
    super.key,
    required this.drinkType,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: drinkType.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: drinkType.color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            drinkType.icon,
            color: drinkType.color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            drinkType.name,
            style: WaterTextStyles.labelLarge.copyWith(
              color: WaterColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
