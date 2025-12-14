// 🥤 Drink Type Selector Widget - Pastel drink icons with selection
import 'package:flutter/material.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:health_care/theme/water_theme.dart';

class DrinkType {
  final String name;
  final IconData icon;
  final Color color;

  const DrinkType({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class DrinkSelector extends StatelessWidget {
  final List<DrinkType> drinks;
  final int selectedIndex;
  final Function(int) onDrinkSelected;
  final Function(int)? onDrinkLongPressed; // Uzun basma için callback

  const DrinkSelector({
    super.key,
    required this.drinks,
    required this.selectedIndex,
    required this.onDrinkSelected,
    this.onDrinkLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: drinks.length + 1, // +1 for "Add new" button
        itemBuilder: (context, index) {
          if (index == drinks.length) {
            return _buildAddButton();
          }

          final drink = drinks[index];
          final isSelected = index == selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _DrinkIcon(
              drink: drink,
              isSelected: isSelected,
              onTap: () => onDrinkSelected(index),
              onLongPress: onDrinkLongPressed != null 
                ? () => onDrinkLongPressed!(index)
                : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: 56,
      height: 56,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.lightTextTertiary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.add,
        color: AppColors.lightTextTertiary,
        size: 24,
      ),
    );
  }
}

class _DrinkIcon extends StatelessWidget {
  final DrinkType drink;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _DrinkIcon({
    required this.drink,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: isSelected ? drink.color : drink.color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? WaterShadows.button : null,
        ),
        child: Icon(
          drink.icon,
          color: isSelected ? Colors.white : drink.color,
          size: 28,
        ),
      ),
    );
  }
}

// Predefined drink types
class DrinkTypes {
  static const List<DrinkType> defaults = [
    DrinkType(
      name: 'Water',
      icon: Icons.water_drop,
      color: WaterColors.drinkWater,
    ),
    DrinkType(
      name: 'Coffee',
      icon: Icons.coffee,
      color: WaterColors.drinkCoffee,
    ),
    DrinkType(
      name: 'Tea',
      icon: Icons.local_cafe,
      color: WaterColors.drinkTea,
    ),
    DrinkType(
      name: 'Matcha',
      icon: Icons.emoji_food_beverage,
      color: WaterColors.drinkMatcha,
    ),
    DrinkType(
      name: 'Soda',
      icon: Icons.local_drink,
      color: WaterColors.drinkSoda,
    ),
    DrinkType(
      name: 'Wine',
      icon: Icons.wine_bar,
      color: WaterColors.drinkWine,
    ),
    // Classic & Most Consumed Herbal Teas
    DrinkType(
      name: 'Linden Tea',
      icon: Icons.spa,
      color: Color(0xFFF5E6D3),
    ),
    DrinkType(
      name: 'Chamomile Tea',
      icon: Icons.local_florist,
      color: Color(0xFFFFF9C4),
    ),
    DrinkType(
      name: 'Sage Tea',
      icon: Icons.grass,
      color: Color(0xFF9CCC65),
    ),
    DrinkType(
      name: 'Mint-Lemon Tea',
      icon: Icons.eco,
      color: Color(0xFFB2DFDB),
    ),
    DrinkType(
      name: 'Rosehip Tea',
      icon: Icons.favorite_border,
      color: Color(0xFFFF8A80),
    ),
    // Relaxing / Stress Relief Teas
    DrinkType(
      name: 'Lemon Balm Tea',
      icon: Icons.self_improvement,
      color: Color(0xFFE1F5DC),
    ),
    DrinkType(
      name: 'Lavender Tea',
      icon: Icons.spa_outlined,
      color: Color(0xFFD1C4E9),
    ),
    DrinkType(
      name: 'Valerian Tea',
      icon: Icons.bedtime,
      color: Color(0xFFB39DDB),
    ),
    DrinkType(
      name: 'Fennel Tea',
      icon: Icons.nature,
      color: Color(0xFFC5E1A5),
    ),
    // Digestive System Teas
    DrinkType(
      name: 'Ginger Tea',
      icon: Icons.health_and_safety,
      color: Color(0xFFFFCC80),
    ),
    DrinkType(
      name: 'Turmeric Tea',
      icon: Icons.healing,
      color: Color(0xFFFFB74D),
    ),
    DrinkType(
      name: 'Anise Tea',
      icon: Icons.wb_sunny,
      color: Color(0xFFDCEDC8),
    ),
    DrinkType(
      name: 'Mate Tea',
      icon: Icons.energy_savings_leaf,
      color: Color(0xFF8BC34A),
    ),
    // Detox & Metabolism Boosting Teas
    DrinkType(
      name: 'Green Tea',
      icon: Icons.local_drink,
      color: Color(0xFF81C784),
    ),
    DrinkType(
      name: 'White Tea',
      icon: Icons.water_drop_outlined,
      color: Color(0xFFF5F5DC),
    ),
    DrinkType(
      name: 'Oolong Tea',
      icon: Icons.emoji_food_beverage,
      color: Color(0xFFD4A574),
    ),
    DrinkType(
      name: 'Hibiscus Tea',
      icon: Icons.local_florist,
      color: Color(0xFFE91E63),
    ),
    // Immunity Boosting Teas
    DrinkType(
      name: 'Echinacea Tea',
      icon: Icons.medical_services,
      color: Color(0xFFCE93D8),
    ),
    DrinkType(
      name: 'Ginger-Honey-Lemon Tea',
      icon: Icons.emoji_nature,
      color: Color(0xFFFFF176),
    ),
    // Cold & Cough Teas
    DrinkType(
      name: 'Clove Tea',
      icon: Icons.coronavirus,
      color: Color(0xFF8D6E63),
    ),
    DrinkType(
      name: 'Cinnamon Tea',
      icon: Icons.thermostat,
      color: Color(0xFFD7B39A),
    ),
    // Women's Health Teas
    DrinkType(
      name: 'Vitex Tea',
      icon: Icons.woman,
      color: Color(0xFFF48FB1),
    ),
    DrinkType(
      name: 'Raspberry Leaf Tea',
      icon: Icons.pregnant_woman,
      color: Color(0xFFFF6F91),
    ),
    // Special & Less Known Herbal Teas
    DrinkType(
      name: 'Moringa Tea',
      icon: Icons.local_pharmacy,
      color: Color(0xFF7CB342),
    ),
    DrinkType(
      name: 'Ginseng Tea',
      icon: Icons.bolt,
      color: Color(0xFFFFE082),
    ),
    DrinkType(
      name: 'Rooibos Tea',
      icon: Icons.brightness_5,
      color: Color(0xFFD32F2F),
    ),
    DrinkType(
      name: 'Rosemary Tea',
      icon: Icons.psychology,
      color: Color(0xFF66BB6A),
    ),
  ];
}
