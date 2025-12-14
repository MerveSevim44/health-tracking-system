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
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: screenHeight * 0.85,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF0F0F1E),
              Color(0xFF252538),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: WaterColors.waterPrimary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    WaterColors.cardBackground,
                    WaterColors.cardBackground.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: WaterColors.waterPrimary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 26,
                    color: WaterColors.waterPrimary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Custom Drink',
                    style: WaterTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: WaterColors.waterPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                        style: WaterTextStyles.bodyMedium.copyWith(
                          color: WaterColors.textDark,
                        ),
                        onChanged: (value) {
                          // Trigger icon animation when name changes
                          if (mounted) setState(() {});
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a drink name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),

                      // Category
                      _buildLabel('Category'),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: _inputDecoration('Select category'),
                        dropdownColor: const Color(0xFF1A1A2E),
                        style: WaterTextStyles.bodyMedium.copyWith(
                          color: WaterColors.textDark,
                          fontSize: 14,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: WaterColors.waterPrimary,
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Text(
                                  DrinkIconGenerator.generateIcon(cat),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  cat[0].toUpperCase() + cat.substring(1),
                                  style: TextStyle(
                                    color: WaterColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _selectedIcon = null;
                            _selectedColor = null;
                          });
                        },
                        selectedItemBuilder: (context) {
                          return _categories.map((cat) {
                            return Row(
                              children: [
                                Text(
                                  DrinkIconGenerator.generateIcon(cat),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  cat[0].toUpperCase() + cat.substring(1),
                                  style: TextStyle(
                                    color: WaterColors.textDark,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                      const SizedBox(height: 24),

                      // Icon Preview
                      _buildLabel('Icon Preview'),
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                (_selectedColor ?? DrinkIconGenerator.generateColor(_selectedCategory)),
                                (_selectedColor ?? DrinkIconGenerator.generateColor(_selectedCategory)).withOpacity(0.6),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_selectedColor ?? DrinkIconGenerator.generateColor(_selectedCategory))
                                    .withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _selectedIcon ?? DrinkIconGenerator.generateIcon(_selectedCategory),
                              style: const TextStyle(fontSize: 44),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Auto-generated icon',
                          style: WaterTextStyles.labelSmall.copyWith(
                            fontSize: 11,
                            color: WaterColors.textLight.withOpacity(0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Benefits
                      _buildLabel('Benefits (Optional)'),
                      TextFormField(
                        controller: _benefitsController,
                        decoration: _inputDecoration('e.g., calms, supports immunity').copyWith(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        ),
                        maxLines: 2,
                        style: WaterTextStyles.bodyMedium.copyWith(
                          color: WaterColors.textDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Harms
                      _buildLabel('Potential Side Effects (Optional)'),
                      TextFormField(
                        controller: _harmsController,
                        decoration: _inputDecoration('e.g., excessive use may cause dizziness').copyWith(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: const Color(0xFFFF9F43).withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: const Color(0xFFFF9F43).withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                        maxLines: 2,
                        style: WaterTextStyles.bodyMedium.copyWith(
                          color: WaterColors.textDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Recommended Daily Intake
                      _buildLabel('Recommended Daily Intake'),
                      TextFormField(
                        controller: _recommendedController,
                        decoration: _inputDecoration('e.g., 1-2 cups'),
                        style: WaterTextStyles.bodyMedium.copyWith(
                          color: WaterColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: (_selectedColor ?? DrinkIconGenerator.generateColor(_selectedCategory))
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: BluePrimaryButton(
                          text: 'Add Drink',
                          onPressed: _handleSubmit,
                          width: double.infinity,
                          icon: Icons.check_circle_outline,
                          color: _selectedColor ?? DrinkIconGenerator.generateColor(_selectedCategory),
                        ),
                      ),
                      const SizedBox(height: 8),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: WaterTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: WaterColors.textDark,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: WaterTextStyles.bodyMedium.copyWith(
        color: WaterColors.textLight.withOpacity(0.6),
        fontSize: 13.5,
      ),
      filled: true,
      fillColor: const Color(0xFF0F0F1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: WaterColors.waterPrimary.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: const Color(0xFFFF6B9D).withOpacity(0.6),
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFFF6B9D),
          width: 1.5,
        ),
      ),
      errorStyle: TextStyle(
        color: const Color(0xFFFF6B9D),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}
