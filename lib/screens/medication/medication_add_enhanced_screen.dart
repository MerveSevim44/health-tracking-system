// 📁 lib/screens/medication/medication_add_enhanced_screen.dart
// Enhanced medication add screen with type selection and automatic intake generation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/models/medication_type_config.dart';
import 'package:health_care/services/medication_intake_calculator.dart';
import 'package:health_care/theme/app_theme.dart';

class MedicationAddEnhancedScreen extends StatefulWidget {
  const MedicationAddEnhancedScreen({super.key});

  @override
  State<MedicationAddEnhancedScreen> createState() => _MedicationAddEnhancedScreenState();
}

class _MedicationAddEnhancedScreenState extends State<MedicationAddEnhancedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _instructionsController = TextEditingController();

  MedicationType _selectedType = MedicationType.tablet;
  MedicationFrequency _frequency = const MedicationFrequency(morning: true);
  DateTime _startDate = DateTime.now();
  int _calculatedDays = 0;
  int _calculatedIntakes = 0;
  
  // Weekly schedule
  Set<int> _selectedWeekDays = {1, 2, 3, 4, 5, 6, 7}; // All days selected by default
  bool _useWeeklySchedule = false; // false = daily, true = specific days

  @override
  void initState() {
    super.initState();
    // Set default dosage
    _dosageController.text = _selectedType.defaultDosage;
    // Set default frequency from type
    _setDefaultFrequency();
    
    // Add listeners for auto-calculation
    _dosageController.addListener(_calculateIntakes);
    _totalAmountController.addListener(_calculateIntakes);
  }

  void _setDefaultFrequency() {
    final recommendation = _selectedType.recommendedFrequency;
    _frequency = MedicationFrequency(
      morning: recommendation.morning,
      afternoon: recommendation.afternoon,
      evening: recommendation.evening,
    );
  }

  void _calculateIntakes() {
    final totalAmount = int.tryParse(_totalAmountController.text) ?? 0;
    if (totalAmount == 0) {
      setState(() {
        _calculatedDays = 0;
        _calculatedIntakes = 0;
      });
      return;
    }

    final intakes = MedicationIntakeCalculator.calculateTotalIntakes(
      type: _selectedType,
      totalAmount: totalAmount,
      dosage: _dosageController.text,
      frequency: _frequency,
    );

    int days = MedicationIntakeCalculator.calculateDurationDays(
      totalIntakes: intakes,
      frequency: _frequency,
    );

    // If using weekly schedule, adjust days calculation
    if (_useWeeklySchedule && _selectedWeekDays.isNotEmpty) {
      // Calculate how many weeks needed
      final daysPerWeek = _selectedWeekDays.length;
      final weeks = (days / daysPerWeek).ceil();
      days = weeks * 7; // Convert to actual calendar days
    }

    setState(() {
      _calculatedIntakes = intakes;
      _calculatedDays = days;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _totalAmountController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
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
                      // Medication Type Selection
                      _buildSectionTitle('Medication Type'),
                      const SizedBox(height: 12),
                      _buildTypeSelector(),

                      const SizedBox(height: 24),

                      // Medication Name
                      _buildSectionTitle('Medication Name'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _nameController,
                        hint: 'e.g. Vitamin C',
                        icon: Icons.medical_services,
                      ),

                      const SizedBox(height: 24),

                      // Dosage and Total Amount in a card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _selectedType.color.withValues(alpha: 0.1),
                              _selectedType.color.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dosage with suggestion
                            _buildSectionTitle('Dosage'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedType.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, 
                                    size: 16, 
                                    color: _selectedType.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Önerilen: ${_selectedType.defaultDosage}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _selectedType.color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _dosageController,
                              hint: 'e.g. 2 tablets',
                              icon: Icons.medication,
                            ),
                            const SizedBox(height: 20),

                            // Total Amount
                            _buildSectionTitle('Toplam Miktar'),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _totalAmountController,
                              hint: 'örn. 30 (tablet sayısı veya ml)',
                              icon: Icons.inventory_2,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Frequency - User decides
                      _buildSectionTitle('When will you take it?'),
                      const SizedBox(height: 8),
                      Text(
                        'Select your daily usage times',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFrequencySelector(),

                      const SizedBox(height: 24),

                      // Weekly Schedule
                      _buildSectionTitle('Weekly Schedule'),
                      const SizedBox(height: 8),
                      Text(
                        'Select the days you will take the medication',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildWeeklyScheduleToggle(),
                      if (_useWeeklySchedule) ...[
                        const SizedBox(height: 12),
                        _buildWeekDaySelector(),
                      ],

                      const SizedBox(height: 24),

                      // Usage Instructions - Optional
                      Builder(
                        builder: (context) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                Icon(Icons.info_outline, 
                                  size: 20, 
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Usage Instructions (Optional)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark 
                                      ? const Color(0xFF9D84FF).withValues(alpha: 0.15)
                                      : const Color(0xFFF3EFFF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _selectedType.usageInstructions,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(0xFF9D84FF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _instructionsController,
                                hint: 'Doctor notes or special instructions...',
                                icon: Icons.notes,
                                maxLines: 3,
                                isRequired: false,
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }
                      ),

                      const SizedBox(height: 24),

                      // Start Date
                      _buildSectionTitle('Start Date'),
                      const SizedBox(height: 12),
                      _buildDateSelector(),

                      const SizedBox(height: 24),

                      // Calculation Summary
                      if (_calculatedDays > 0) ...[
                        _buildCalculationSummary(),
                        const SizedBox(height: 24),
                      ],

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBg : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                color: theme.textTheme.bodyLarge?.color,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'İlaç Ekle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: theme.textTheme.bodyLarge?.color,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTypeSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE8E8E8)),
      ),
      child: DropdownButtonFormField<MedicationType>(
        value: _selectedType,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          prefixIcon: Icon(Icons.category, color: Color(0xFF9D84FF)),
        ),
        dropdownColor: isDark ? AppColors.darkCardBg : Colors.white,
        items: MedicationType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Row(
              children: [
                Icon(type.icon, size: 20, color: type.color),
                const SizedBox(width: 12),
                Text(
                  type.displayName,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedType = value;
              _dosageController.text = value.defaultDosage;
              _setDefaultFrequency();
              _calculateIntakes();
            });
          }
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    Function(String)? onChanged,
    bool isRequired = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 18,
        color: isDark ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.none,
      ),
      cursorColor: const Color(0xFF9D84FF),
      cursorWidth: 2,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? const Color(0xFF252538) : Colors.white,
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white60 : Colors.black45,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF9D84FF), size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3A3A4E) : const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3A3A4E) : const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF9D84FF),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      validator: isRequired ? (value) {
        if (value == null || value.isEmpty) {
          return 'Bu alan zorunludur';
        }
        return null;
      } : null,
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      children: [
        _buildFrequencyOption('Morning', _frequency.morning, (value) {
          setState(() {
            _frequency = _frequency.copyWith(morning: value);
            _calculateIntakes();
          });
        }),
        const SizedBox(height: 10),
        _buildFrequencyOption('Afternoon', _frequency.afternoon, (value) {
          setState(() {
            _frequency = _frequency.copyWith(afternoon: value);
            _calculateIntakes();
          });
        }),
        const SizedBox(height: 10),
        _buildFrequencyOption('Evening', _frequency.evening, (value) {
          setState(() {
            _frequency = _frequency.copyWith(evening: value);
            _calculateIntakes();
          });
        }),
      ],
    );
  }

  Widget _buildFrequencyOption(String label, bool value, Function(bool) onChanged) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: value
              ? const LinearGradient(
                  colors: [Color(0xFF9D84FF), Color(0xFFB8A4FF)],
                )
              : null,
          color: value ? null : (isDark ? AppColors.darkCardBg : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? Colors.transparent : (isDark ? AppColors.darkBorder : const Color(0xFFE8E8E8)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              color: value ? Colors.white : const Color(0xFF9D84FF),
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: value ? Colors.white : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _startDate = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBg : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF9D84FF), size: 22),
            const SizedBox(width: 12),
            Text(
              '${_startDate.day}/${_startDate.month}/${_startDate.year}',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationSummary() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9D84FF).withValues(alpha: 0.15),
            const Color(0xFFB8A4FF).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF9D84FF).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D84FF).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF9D84FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Automatic Planning',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBg : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDark ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Column(
              children: [
                _buildSummaryRow('Total usage', '$_calculatedIntakes times', Icons.repeat),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : null),
                _buildSummaryRow('Duration', '$_calculatedDays days', Icons.calendar_today),
                Divider(height: 20, color: isDark ? AppColors.darkBorder : null),
                _buildSummaryRow('End date', _getEndDate(), Icons.event),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF06D6A0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF06D6A0), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Medication calendar will be created automatically',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF06D6A0).withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9D84FF)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9D84FF),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _getEndDate() {
    final endDate = _startDate.add(Duration(days: _calculatedDays));
    return '${endDate.day}/${endDate.month}/${endDate.year}';
  }

  Widget _buildWeeklyScheduleToggle() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE8E8E8)),
      ),
      child: SwitchListTile(
        title: Text(
          'Specific days of the week',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          _useWeeklySchedule 
              ? '${_selectedWeekDays.length} days selected'
              : 'Use every day',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        value: _useWeeklySchedule,
        activeColor: const Color(0xFF9D84FF),
        onChanged: (value) {
          setState(() {
            _useWeeklySchedule = value;
            _calculateIntakes();
          });
        },
      ),
    );
  }

  Widget _buildWeekDaySelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    const weekDays = [
      {'name': 'Pzt', 'value': 1},
      {'name': 'Sal', 'value': 2},
      {'name': 'Çar', 'value': 3},
      {'name': 'Per', 'value': 4},
      {'name': 'Cum', 'value': 5},
      {'name': 'Cmt', 'value': 6},
      {'name': 'Paz', 'value': 7},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE8E8E8)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: weekDays.map((day) {
          final isSelected = _selectedWeekDays.contains(day['value'] as int);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedWeekDays.remove(day['value'] as int);
                } else {
                  _selectedWeekDays.add(day['value'] as int);
                }
                _calculateIntakes();
              });
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF9D84FF)
                    : (isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF9D84FF)
                      : (isDark ? AppColors.darkBorder : const Color(0xFFE8E8E8)),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  day['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
            Icon(Icons.check_circle, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'Add Medication & Create Calendar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddMedication(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (!_frequency.morning && !_frequency.afternoon && !_frequency.evening) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one time of day'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final totalAmount = int.tryParse(_totalAmountController.text);
    if (totalAmount == null || totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Create medication
      final medication = MedicationFirebase(
        id: '',
        name: _nameController.text,
        dosage: _dosageController.text,
        instructions: _instructionsController.text,
        startDate: _startDate.toIso8601String(),
        active: true,
        frequency: _frequency,
        type: _selectedType.toFirebaseValue(),
        totalAmount: totalAmount,
        endDate: _startDate.add(Duration(days: _calculatedDays)).toIso8601String(),
      );

      // Add medication and get ID
      final medicationId = await context.read<MedicationModel>().addMedicationEnhanced(medication);

      // Generate intakes
      if (_calculatedDays > 0) {
        final List<IntakeSchedule> schedules;
        
        if (_useWeeklySchedule && _selectedWeekDays.isNotEmpty) {
          schedules = MedicationIntakeCalculator.generateWeeklyIntakeSchedule(
            startDate: _startDate,
            durationDays: _calculatedDays,
            frequency: _frequency,
            dosage: _dosageController.text,
            weekDays: _selectedWeekDays,
          );
        } else {
          schedules = MedicationIntakeCalculator.generateIntakeSchedule(
            startDate: _startDate,
            durationDays: _calculatedDays,
            frequency: _frequency,
            dosage: _dosageController.text,
          );
        }

        final intakes = schedules.map((s) => s.toIntake(medicationId)).toList();
        await context.read<MedicationModel>().generateIntakes(medicationId, intakes);
      }

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close add screen

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${medication.name} added! $_calculatedIntakes reminders created.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF06D6A0),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
