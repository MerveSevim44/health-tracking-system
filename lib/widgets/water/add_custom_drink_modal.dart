// 📁 lib/widgets/water/add_custom_drink_modal.dart
// Custom drink ekleme modal formu

import 'package:flutter/material.dart';
import 'package:health_care/models/custom_drink_model.dart';
import 'package:health_care/theme/water_theme.dart';
import 'package:health_care/widgets/water/blur_card.dart';

class AddCustomDrinkModal extends StatefulWidget {
  final Function(CustomDrink) onDrinkAdded;

  const AddCustomDrinkModal({
    super.key,
    required this.onDrinkAdded,
  });

  @override
  State<AddCustomDrinkModal> createState() => _AddCustomDrinkModalState();
}

class _AddCustomDrinkModalState extends State<AddCustomDrinkModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _harmsController = TextEditingController();
  final _recommendedController = TextEditingController();
  
  String _selectedCategory = 'herbal';
  String? _selectedIcon;
  Color? _selectedColor;

  final List<String> _categories = [
    'herbal',
    'tea',
    'coffee',
    'juice',
    'custom',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _benefitsController.dispose();
    _harmsController.dispose();
    _recommendedController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Otomatik ikon ve renk oluştur
      final icon = _selectedIcon ?? DrinkIconGenerator.generateIcon(_selectedCategory);
      final color = _selectedColor ?? DrinkIconGenerator.generateColor(_selectedCategory);

      final drink = CustomDrink(
        id: '', // Firebase tarafından atanacak
        name: _nameController.text.trim(),
        benefits: _benefitsController.text.trim().isNotEmpty 
          ? _benefitsController.text.trim() 
          : null,
        harms: _harmsController.text.trim().isNotEmpty 
          ? _harmsController.text.trim() 
          : null,
        recommendedIntake: _recommendedController.text.trim().isNotEmpty 
          ? _recommendedController.text.trim() 
          : '1-2 cups daily',
        iconUrl: icon,
        color: color,
        category: _selectedCategory,
        isPredefined: false,
        createdAt: DateTime.now(),
      );

      widget.onDrinkAdded(drink);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: WaterShadows.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: WaterColors.waterLight.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Add Custom Drink',
                    style: WaterTextStyles.headlineMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drink Name
                      _buildLabel('Drink Name *'),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('e.g., Linden Tea'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a drink name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Category
                      _buildLabel('Category'),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: _inputDecoration('Select category'),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat[0].toUpperCase() + cat.substring(1)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _selectedIcon = null;
                            _selectedColor = null;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Icon Preview
                      _buildLabel('Icon Preview'),
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: (_selectedColor ?? DrinkIconGenerator.generateColor(_selectedCategory))
                                .withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor ?? DrinkIconGenerator.generateColor(_selectedCategory),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _selectedIcon ?? DrinkIconGenerator.generateIcon(_selectedCategory),
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Auto-generated icon',
                          style: WaterTextStyles.labelSmall,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Benefits
                      _buildLabel('Benefits (Optional)'),
                      TextFormField(
                        controller: _benefitsController,
                        decoration: _inputDecoration('e.g., calms, supports immunity'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),

                      // Harms
                      _buildLabel('Potential Side Effects (Optional)'),
                      TextFormField(
                        controller: _harmsController,
                        decoration: _inputDecoration('e.g., excessive use may cause dizziness'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),

                      // Recommended Daily Intake
                      _buildLabel('Recommended Daily Intake'),
                      TextFormField(
                        controller: _recommendedController,
                        decoration: _inputDecoration('e.g., 1-2 cups'),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      BluePrimaryButton(
                        text: 'Add Drink',
                        onPressed: _handleSubmit,
                        width: double.infinity,
                        icon: Icons.check,
                        color: _selectedColor ?? DrinkIconGenerator.generateColor(_selectedCategory),
                      ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: WaterTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: WaterTextStyles.bodyMedium.copyWith(
        color: WaterColors.textLight,
      ),
      filled: true,
      fillColor: WaterColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: WaterColors.waterPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
