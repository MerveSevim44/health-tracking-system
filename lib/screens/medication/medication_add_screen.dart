import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/theme/modern_colors.dart';
import 'dart:ui';

enum MedicationCategory { morning, afternoon, evening }

class MedicationAddScreen extends StatefulWidget {
  const MedicationAddScreen({super.key});

  @override
  State<MedicationAddScreen> createState() => _MedicationAddScreenState();
}

class _MedicationAddScreenState extends State<MedicationAddScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _totalAmountController = TextEditingController();

  final Set<MedicationCategory> _selectedFrequencies = {MedicationCategory.morning};
  final Set<int> _selectedDays = {1, 2, 3, 4, 5}; // 1=Monday to 7=Sunday
  String _selectedIcon = 'pill';
  Color _selectedColor = const Color(0xFFFF9F43);
  bool _isSaving = false;
  late AnimationController _floatController;

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'pill', 'icon': Icons.medication_rounded, 'label': 'Pill'},
    {'name': 'capsule', 'icon': Icons.medication_liquid_rounded, 'label': 'Capsule'},
    {'name': 'bottle', 'icon': Icons.local_drink_rounded, 'label': 'Bottle'},
    {'name': 'vitamin', 'icon': Icons.restaurant_rounded, 'label': 'Vitamin'},
    {'name': 'injection', 'icon': Icons.vaccines_rounded, 'label': 'Injection'},
    {'name': 'drops', 'icon': Icons.water_drop_rounded, 'label': 'Drops'},
    {'name': 'syrup', 'icon': Icons.science_rounded, 'label': 'Syrup'},
    {'name': 'inhaler', 'icon': Icons.air_rounded, 'label': 'Inhaler'},
  ];

  final List<Color> _colorOptions = [
    const Color(0xFFFF9F43), // Orange
    const Color(0xFF6C63FF), // Purple
    const Color(0xFF00D4FF), // Cyan
    const Color(0xFFFF6B9D), // Pink
    const Color(0xFF00D9A3), // Green
    const Color(0xFFFECA57), // Yellow
    const Color(0xFFE74C3C), // Red
    const Color(0xFF3498DB), // Blue
    const Color(0xFF9B59B6), // Lavender
    const Color(0xFF1ABC9C), // Turquoise
  ];

  final List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _totalAmountController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  String? _calculateEndDate() {
    if (_totalAmountController.text.isEmpty || _selectedDays.isEmpty) {
      return null;
    }

    try {
      final totalAmount = int.parse(_totalAmountController.text);
      final dosesPerDay = _selectedFrequencies.length; // Total doses per occurrence
      final daysPerWeek = _selectedDays.length;
      
      // Calculate total occurrences needed
      final totalOccurrences = (totalAmount / dosesPerDay).ceil();
      
      // Calculate total weeks needed
      final weeksNeeded = (totalOccurrences / daysPerWeek).ceil();
      
      // Calculate end date
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: weeksNeeded * 7));
      
      return endDate.toIso8601String();
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedFrequencies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one time of day'),
          backgroundColor: ModernAppColors.error,
        ),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day of the week'),
          backgroundColor: ModernAppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final medicationModel = context.read<MedicationModel>();
      
      final endDate = _calculateEndDate();
      final totalAmount = _totalAmountController.text.isNotEmpty 
          ? int.tryParse(_totalAmountController.text) 
          : null;

      final medication = MedicationFirebase(
        id: '',
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        instructions: _instructionsController.text.trim(),
        startDate: DateTime.now().toIso8601String(),
        active: true,
        frequency: MedicationFrequency(
          morning: _selectedFrequencies.contains(MedicationCategory.morning),
          afternoon: _selectedFrequencies.contains(MedicationCategory.afternoon),
          evening: _selectedFrequencies.contains(MedicationCategory.evening),
        ),
        type: _selectedIcon,
        totalAmount: totalAmount,
        remainingAmount: totalAmount,
        endDate: endDate,
        color: '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
        icon: _selectedIcon,
        daysOfWeek: _selectedDays.toList(),
      );
      
      debugPrint('[ADD MED] Saving medication with color: #${_selectedColor.value.toRadixString(16).substring(2)} icon: $_selectedIcon days: ${_selectedDays.toList()}');

      await medicationModel.addMedicationEnhanced(medication);

      if (mounted) {
        // Show success message with calculation details
        String message = 'Medication added successfully!';
        if (totalAmount != null && endDate != null) {
          final weeksNeeded = ((totalAmount / (_selectedFrequencies.length * _selectedDays.length)).ceil());
          message += '\nScheduled for ~$weeksNeeded weeks';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: ModernAppColors.accentGreen,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ModernAppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernAppColors.darkBg,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          
                          // Icon Selector
                          _buildSectionLabel('Medication Icon'),
                          const SizedBox(height: 12),
                          _buildIconSelector(),
                          
                          const SizedBox(height: 24),
                          
                          // Color Selector
                          _buildSectionLabel('Color'),
                          const SizedBox(height: 12),
                          _buildColorSelector(),
                          
                          const SizedBox(height: 24),
                          
                          // Medication Name
                          _buildSectionLabel('Medication Name'),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'e.g., Aspirin',
                            icon: Icons.medical_services_rounded,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Dosage
                          _buildSectionLabel('Dosage'),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _dosageController,
                            hint: 'e.g., 100mg, 2 pills',
                            icon: Icons.medication_rounded,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Total Amount
                          _buildSectionLabel('Total Dosages/Pills'),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _totalAmountController,
                            hint: 'e.g., 30 pills',
                            icon: Icons.inventory_rounded,
                            keyboardType: TextInputType.number,
                            required: false,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Instructions
                          _buildSectionLabel('Instructions (Optional)'),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _instructionsController,
                            hint: 'e.g., Take with food',
                            icon: Icons.note_rounded,
                            maxLines: 3,
                            required: false,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Frequency Selection
                          _buildSectionLabel('When to take each day'),
                          const SizedBox(height: 12),
                          _buildFrequencySelector(),
                          
                          const SizedBox(height: 32),
                          
                          // Days of Week Selection
                          _buildSectionLabel('Which days of the week'),
                          const SizedBox(height: 12),
                          _buildDaySelector(),
                          
                          const SizedBox(height: 24),
                          
                          // Schedule info
                          if (_totalAmountController.text.isNotEmpty && _selectedDays.isNotEmpty)
                            _buildScheduleInfo(),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                
                _buildSaveButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: ModernAppColors.backgroundGradient,
          ),
        ),
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Positioned(
              top: 200 + (_floatController.value * 50),
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _selectedColor.withOpacity(0.3),
                      _selectedColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ModernAppColors.cardBg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: ModernAppColors.lightText,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Add Medication',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ModernAppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ModernAppColors.lightText,
      ),
    );
  }

  Widget _buildIconSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _iconOptions.map((iconData) {
        final isSelected = _selectedIcon == iconData['name'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIcon = iconData['name'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected 
                  ? _selectedColor.withOpacity(0.3)
                  : ModernAppColors.cardBg,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected 
                    ? _selectedColor 
                    : ModernAppColors.mutedText.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData['icon'] as IconData,
                  color: isSelected ? _selectedColor : ModernAppColors.mutedText,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  iconData['label'] as String,
                  style: TextStyle(
                    color: isSelected ? _selectedColor : ModernAppColors.mutedText,
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? ModernAppColors.lightText : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: ModernAppColors.lightText,
                    size: 24,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool required = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: ModernAppColors.cardBg.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _selectedColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
            cursorColor: Colors.white,
            cursorWidth: 2,
            decoration: InputDecoration(
              filled: true,
              fillColor: ModernAppColors.cardBg.withOpacity(0.6),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.white60,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            validator: required
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    final frequencies = [
      {'value': MedicationCategory.morning, 'label': 'Morning', 'icon': Icons.wb_sunny_rounded},
      {'value': MedicationCategory.afternoon, 'label': 'Afternoon', 'icon': Icons.wb_twilight_rounded},
      {'value': MedicationCategory.evening, 'label': 'Evening', 'icon': Icons.nightlight_round},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: frequencies.map((freq) {
        final category = freq['value'] as MedicationCategory;
        final isSelected = _selectedFrequencies.contains(category);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedFrequencies.remove(category);
              } else {
                _selectedFrequencies.add(category);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: isSelected 
                  ? LinearGradient(colors: [_selectedColor, _selectedColor.withOpacity(0.7)])
                  : null,
              color: isSelected ? null : ModernAppColors.cardBg,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : ModernAppColors.mutedText.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _selectedColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  freq['icon'] as IconData,
                  color: isSelected
                      ? ModernAppColors.lightText
                      : ModernAppColors.mutedText,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  freq['label'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? ModernAppColors.lightText
                        : ModernAppColors.mutedText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final dayNumber = index + 1;
        final isSelected = _selectedDays.contains(dayNumber);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(dayNumber);
              } else {
                _selectedDays.add(dayNumber);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isSelected ? _selectedColor : ModernAppColors.cardBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected 
                    ? _selectedColor 
                    : ModernAppColors.mutedText.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _selectedColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                _dayLabels[index],
                style: TextStyle(
                  color: isSelected
                      ? ModernAppColors.lightText
                      : ModernAppColors.mutedText,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScheduleInfo() {
    try {
      final totalAmount = int.parse(_totalAmountController.text);
      final dosesPerDay = _selectedFrequencies.length;
      final daysPerWeek = _selectedDays.length;
      
      final dosesPerWeek = dosesPerDay * daysPerWeek;
      final weeksNeeded = (totalAmount / dosesPerWeek).ceil();
      final totalDays = weeksNeeded * 7;
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _selectedColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: _selectedColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Medication Schedule',
                  style: TextStyle(
                    color: _selectedColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildScheduleRow('Total doses', '$totalAmount'),
            _buildScheduleRow('Doses per day', '$dosesPerDay'),
            _buildScheduleRow('Days per week', '$daysPerWeek'),
            _buildScheduleRow('Duration', '~$weeksNeeded weeks ($totalDays days)'),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildScheduleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ModernAppColors.mutedText,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ModernAppColors.lightText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_selectedColor, _selectedColor.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _selectedColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveMedication,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: ModernAppColors.lightText,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, color: ModernAppColors.lightText),
                    SizedBox(width: 10),
                    Text(
                      'Save Medication',
                      style: TextStyle(
                        color: ModernAppColors.lightText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
