// 📁 lib/widgets/water/today_drink_logs.dart
// Bugünün içecek loglarını gösteren widget

import 'package:flutter/material.dart';
import 'package:health_care/models/custom_drink_model.dart';
import 'package:health_care/theme/water_theme.dart';

class TodayDrinkLogs extends StatelessWidget {
  final List<DrinkLog> logs;
  final Function(String)? onDeleteLog;
  final DateTime selectedDate;

  const TodayDrinkLogs({
    super.key,
    required this.logs,
    this.onDeleteLog,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(
                Icons.history,
                size: 24,
                color: WaterColors.textDark,
              ),
              const SizedBox(width: 8),
              Text(
                _getTitle(),
                style: WaterTextStyles.headlineMedium,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: WaterColors.waterPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${logs.length} ${logs.length == 1 ? 'item' : 'items'}',
                  style: WaterTextStyles.labelSmall.copyWith(
                    color: WaterColors.waterPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          color: WaterColors.textLight.withValues(alpha: 0.2),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: logs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildLogItem(context, log);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.local_drink_outlined,
            size: 64,
            color: WaterColors.textLight.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No drinks logged today',
            style: WaterTextStyles.bodyMedium.copyWith(
              color: WaterColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your hydration!',
            style: WaterTextStyles.labelSmall.copyWith(
              color: WaterColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(BuildContext context, DrinkLog log) {
    return Container(
      decoration: BoxDecoration(
        color: log.color?.withValues(alpha: 0.05) ?? WaterColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: log.color?.withValues(alpha: 0.2) ?? WaterColors.textLight.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Dismissible(
        key: Key(log.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
        onDismissed: (direction) {
          if (onDeleteLog != null) {
            onDeleteLog!(log.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Time
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: log.color?.withValues(alpha: 0.15) ?? WaterColors.waterLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  log.formattedTime,
                  style: WaterTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: log.color ?? WaterColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),

              // Icon
              if (log.iconUrl != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: log.color?.withValues(alpha: 0.2) ?? WaterColors.waterLight.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      log.iconUrl!,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              const SizedBox(width: 12),

              // Drink info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.drinkName,
                      style: WaterTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: WaterColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      log.displayText,
                      style: WaterTextStyles.labelSmall.copyWith(
                        color: WaterColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: log.color ?? WaterColors.waterPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  log.drinkName.toLowerCase() == 'water' 
                    ? '${log.amount}ml' 
                    : '${log.cups} cup${log.cups > 1 ? 's' : ''}',
                  style: WaterTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    if (selected == today) {
      return "Today's Intake";
    } else {
      // Format: "12 Dec's Intake" veya "Mon, 12 Dec"
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return "${days[selectedDate.weekday - 1]}, ${selectedDate.day} ${months[selectedDate.month - 1]}";
    }
  }
}
