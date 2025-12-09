// 💧 Water Amount Counter - Stepper with + and - buttons
import 'package:flutter/material.dart';
import 'package:health_care/theme/water_theme.dart';

class WaterCounter extends StatelessWidget {
  final int currentAmount; // in ml
  final int step; // increment/decrement step
  final Function(int) onAmountChanged;
  final int minAmount;
  final int maxAmount;

  const WaterCounter({
    super.key,
    required this.currentAmount,
    this.step = 50,
    required this.onAmountChanged,
    this.minAmount = 0,
    this.maxAmount = 5000,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: WaterColors.waterLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(
            icon: Icons.remove,
            onPressed: currentAmount > minAmount
                ? () => onAmountChanged(currentAmount - step)
                : null,
          ),
          const SizedBox(width: 40),
          _buildAmountDisplay(),
          const SizedBox(width: 40),
          _buildButton(
            icon: Icons.add,
            onPressed: currentAmount < maxAmount
                ? () => onAmountChanged(currentAmount + step)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: onPressed != null
                ? WaterColors.waterPrimary
                : WaterColors.textLight.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$currentAmount ml',
          style: WaterTextStyles.displayMedium.copyWith(
            fontSize: 28,
            color: WaterColors.waterDark,
          ),
        ),
      ],
    );
  }
}

// Quick amount selector buttons
class QuickAmountSelector extends StatelessWidget {
  final List<int> amounts;
  final Function(int) onAmountSelected;

  const QuickAmountSelector({
    super.key,
    this.amounts = const [50, 100, 150, 200, 250, 500],
    required this.onAmountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amounts.map((amount) {
        return _buildQuickButton(amount);
      }).toList(),
    );
  }

  Widget _buildQuickButton(int amount) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAmountSelected(amount),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: WaterColors.waterLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: WaterColors.waterPrimary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            '$amount ml',
            style: WaterTextStyles.labelLarge.copyWith(
              color: WaterColors.waterDark,
            ),
          ),
        ),
      ),
    );
  }
}
