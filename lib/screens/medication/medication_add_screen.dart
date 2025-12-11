import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/widgets/medication/pill_icon.dart';
import 'package:health_care/widgets/medication/time_selector.dart';
import 'package:health_care/theme/app_theme.dart';

// 📁 lib/screens/medication/medication_add_screen.dart

class MedicationAddScreen extends StatefulWidget {
  const MedicationAddScreen({super.key});

  @override
  State<MedicationAddScreen> createState() => _MedicationAddScreenState();
}

class _MedicationAddScreenState extends State<MedicationAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  // Multiple frequency selection (morning, afternoon, evening)
  final Set<MedicationCategory> _selectedFrequencies = {MedicationCategory.morning};
  MedicationIcon _selectedIcon = MedicationIcon.pill;
  MealTiming _selectedMealTiming = MealTiming.anytime;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  Color _selectedColor = const Color(0xFF9D84FF);

  final List<Color> _colorOptions = const [
    Color(0xFF9D84FF), // Purple
    Color(0xFFFFD166), // Yellow
    Color(0xFF06D6A0), // Mint
    Color(0xFFFF6B6B), // Pink-red
    Color(0xFF4FC3F7), // Blue
    Color(0xFFFFCC80), // Orange
    Color(0xFFCE93D8), // Lavender
    Color(0xFFA5D6A7), // Green
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Medication Name
                      const Text(
                        'Medication Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _nameController,
                        hint: 'e.g., Vitamin C',
                        icon: Icons.medical_services,
                      ),

                      const SizedBox(height: 24),

                      // Dosage
                      const Text(
                        'Dosage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _dosageController,
                        hint: 'e.g., 2 caps, 1 pill',
                        icon: Icons.medication,
                      ),

                      const SizedBox(height: 24),

                      // Schedule Category
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCategorySelector(),

                      const SizedBox(height: 24),

                      // Time
                      const Text(
                        'Notification Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MedicationTimeSelector(
                        selectedTime: _selectedTime,
                        onTimeChanged: (time) {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Meal Timing
                      const Text(
                        'Meal Timing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMealTimingSelector(),

                      const SizedBox(height: 24),

                      // Icon
                      const Text(
                        'Choose Icon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PillIconSelector(
                        selectedIcon: _selectedIcon,
                        onIconSelected: (icon) {
                          setState(() {
                            _selectedIcon = icon;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Color
                      const Text(
                        'Choose Color',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildColorSelector(),

                      const SizedBox(height: 32),

                      // Add Button
                      _buildAddButton(context),

                      const SizedBox(height: 24),
                    ],
                  ),
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
                'Add Medication',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textLight.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF9D84FF),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    // Only show morning, afternoon, evening (exclude night)
    final categories = [
      MedicationCategory.morning,
      MedicationCategory.afternoon,
      MedicationCategory.evening,
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((category) {
        final isSelected = _selectedFrequencies.contains(category);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedFrequencies.remove(category);
                } else {
                  _selectedFrequencies.add(category);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF9D84FF), Color(0xFFB8A4FF)],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFFE8E8E8),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.white : const Color(0xFF9D84FF),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getCategoryText(category),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMealTimingSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: MealTiming.values.map((timing) {
        final isSelected = _selectedMealTiming == timing;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMealTiming = timing;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE8DEFF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF9D84FF)
                    : const Color(0xFFE8E8E8),
                width: 1,
              ),
            ),
            child: Text(
              _getMealTimingText(timing),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF9D84FF)
                    : AppColors.textDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colorOptions.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleAddMedication(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9D84FF), Color(0xFFB8A4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9D84FF).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Add Medication',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryText(MedicationCategory category) {
    switch (category) {
      case MedicationCategory.morning:
        return 'Morning';
      case MedicationCategory.afternoon:
        return 'Afternoon';
      case MedicationCategory.evening:
        return 'Evening';
      case MedicationCategory.night:
        return 'Night';
    }
  }

  String _getMealTimingText(MealTiming timing) {
    switch (timing) {
      case MealTiming.beforeMeal:
        return 'Before Meal';
      case MealTiming.afterMeal:
        return 'After Meal';
      case MealTiming.withMeal:
        return 'With Meal';
      case MealTiming.anytime:
        return 'Anytime';
    }
  }

  void _handleAddMedication(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Validate at least one frequency is selected
      if (_selectedFrequencies.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select at least one time (Morning, Afternoon, or Evening)'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }
      
      // Use the first selected frequency for UI compatibility
      final primaryCategory = _selectedFrequencies.first;
      
      // Create frequency object from selected frequencies
      final frequency = MedicationFrequency(
        morning: _selectedFrequencies.contains(MedicationCategory.morning),
        afternoon: _selectedFrequencies.contains(MedicationCategory.afternoon),
        evening: _selectedFrequencies.contains(MedicationCategory.evening),
      );
      
      final medication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        dosage: _dosageController.text,
        category: primaryCategory,
        time: _selectedTime,
        icon: _selectedIcon,
        mealTiming: _selectedMealTiming,
        color: _selectedColor,
        pillsLeft: 30,
        totalPills: 30,
        frequencyOverride: frequency,
      );

      context.read<MedicationModel>().addMedication(medication);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('${medication.name} added successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF06D6A0),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }
}
