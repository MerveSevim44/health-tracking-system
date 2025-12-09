import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/widgets/medication/pill_icon.dart';
import 'package:health_care/widgets/medication/action_buttons.dart';
import 'package:health_care/widgets/medication/time_selector.dart';
import 'package:health_care/theme/app_theme.dart';

// 📁 lib/screens/medication/medication_detail_screen.dart

class MedicationDetailScreen extends StatefulWidget {
  final Medication? medication;

  const MedicationDetailScreen({
    super.key,
    this.medication,
  });

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.medication?.time ?? const TimeOfDay(hour: 8, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    final medication = widget.medication ??
        ModalRoute.of(context)!.settings.arguments as Medication;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Large Pill Icon
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            medication.color.withValues(alpha: 0.2),
                            medication.color.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: medication.color.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: PillIcon(
                          iconType: medication.icon,
                          color: medication.color,
                          size: 60,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Medication Name
                    Text(
                      medication.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Dosage
                    Text(
                      medication.dosage,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textLight,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Time Selector
                    MedicationTimeSelector(
                      selectedTime: _selectedTime,
                      onTimeChanged: (time) {
                        setState(() {
                          _selectedTime = time;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Meal Indicator
                    if (medication.mealTiming != MealTiming.anytime)
                      _buildMealIndicator(medication.mealTiming),

                    const SizedBox(height: 32),

                    // Action Buttons
                    ActionButtons(
                      medication: medication,
                      onAction: (status) => _handleAction(context, medication, status),
                    ),

                    const SizedBox(height: 24),

                    // Pills Left Footer
                    _buildPillsLeftFooter(medication),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textDark,
                size: 24,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Medication Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildMealIndicator(MealTiming timing) {
    String text;
    IconData icon;

    switch (timing) {
      case MealTiming.beforeMeal:
        text = 'Take before meals';
        icon = Icons.restaurant;
        break;
      case MealTiming.afterMeal:
        text = 'Take after meals';
        icon = Icons.restaurant;
        break;
      case MealTiming.withMeal:
        text = 'Take with meals';
        icon = Icons.restaurant;
        break;
      case MealTiming.anytime:
        text = 'Anytime';
        icon = Icons.access_time;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF9D84FF),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillsLeftFooter(Medication medication) {
    final percentage = (medication.pillsLeft / medication.totalPills * 100).round();
    final isLow = percentage < 30;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLow
              ? [
                  const Color(0xFFFFE8F0),
                  const Color(0xFFFFF0F5),
                ]
              : [
                  const Color(0xFFE8F5E3),
                  const Color(0xFFF0F9ED),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLow ? Icons.warning_amber : Icons.inventory_2,
              color: isLow ? const Color(0xFFEF476F) : const Color(0xFF06D6A0),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have ${medication.pillsLeft} pills left',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isLow
                        ? const Color(0xFFEF476F)
                        : const Color(0xFF06D6A0),
                  ),
                ),
                if (isLow) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Time to refill your medication',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8B92A0),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, Medication medication, MedicationStatus status) {
    final model = context.read<MedicationModel>();
    model.logMedicationAction(medication.id, status);

    String message;
    IconData icon;
    Color color;

    switch (status) {
      case MedicationStatus.taken:
        message = 'Great! ${medication.name} taken';
        icon = Icons.check_circle;
        color = const Color(0xFF06D6A0);
        break;
      case MedicationStatus.skipped:
        message = '${medication.name} skipped';
        icon = Icons.close;
        color = const Color(0xFFFF6B6B);
        break;
      case MedicationStatus.postponed:
        message = '${medication.name} postponed';
        icon = Icons.schedule;
        color = const Color(0xFF9D84FF);
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    if (status == MedicationStatus.taken) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }
}
