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

  const DrinkSelector({
    super.key,
    required this.drinks,
    required this.selectedIndex,
    required this.onDrinkSelected,
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
        color: AppColors.textLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.add,
        color: AppColors.textLight,
        size: 24,
      ),
    );
  }
}

class _DrinkIcon extends StatelessWidget {
  final DrinkType drink;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrinkIcon({
    required this.drink,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
      color: AppColors.drinkWater,
    ),
    DrinkType(
      name: 'Coffee',
      icon: Icons.coffee,
      color: AppColors.drinkCoffee,
    ),
    DrinkType(
      name: 'Tea',
      icon: Icons.local_cafe,
      color: AppColors.drinkTea,
    ),
    DrinkType(
      name: 'Matcha',
      icon: Icons.emoji_food_beverage,
      color: AppColors.drinkMatcha,
    ),
    DrinkType(
      name: 'Soda',
      icon: Icons.local_drink,
      color: AppColors.drinkSoda,
    ),
    DrinkType(
      name: 'Wine',
      icon: Icons.wine_bar,
      color: AppColors.drinkWine,
    ),
  ];
}
