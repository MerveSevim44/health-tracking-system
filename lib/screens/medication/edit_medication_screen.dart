// 📁 lib/screens/medication/edit_medication_screen.dart
// Edit existing medication screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/models/medication_type_config.dart';
import 'package:health_care/theme/modern_colors.dart';

class EditMedicationScreen extends StatefulWidget {
  final MedicationFirebase medication;

  const EditMedicationScreen({
    super.key,
    required this.medication,
  });

  @override
  State<EditMedicationScreen> createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _totalAmountController;
  late final TextEditingController _instructionsController;

  late MedicationType _selectedType;
  late MedicationFrequency _frequency;
  late DateTime _startDate;
  late String? _selectedColor;
  late String? _selectedIcon;
  
  // Weekly schedule
  late Set<int> _selectedWeekDays;
  late bool _useWeeklySchedule;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing medication data
    _nameController = TextEditingController(text: widget.medication.name);
    _dosageController = TextEditingController(text: widget.medication.dosage);
    _totalAmountController = TextEditingController(
      text: widget.medication.totalAmount?.toString() ?? ''
    );
    _instructionsController = TextEditingController(
      text: widget.medication.instructions
    );

    _selectedType = _getMedicationTypeFromString(widget.medication.type ?? 'tablet');
    _frequency = widget.medication.frequency;
    _startDate = DateTime.parse(widget.medication.startDate);
    _selectedColor = widget.medication.color;
    _selectedIcon = widget.medication.icon;
    
    // Initialize week days
    if (widget.medication.daysOfWeek != null && widget.medication.daysOfWeek!.isNotEmpty) {
      _selectedWeekDays = Set<int>.from(widget.medication.daysOfWeek!);
      _useWeeklySchedule = true;
    } else {
      _selectedWeekDays = {1, 2, 3, 4, 5, 6, 7};
      _useWeeklySchedule = false;
    }

    // Add listeners to detect changes
    _nameController.addListener(() => setState(() => _hasChanges = true));
    _dosageController.addListener(() => setState(() => _hasChanges = true));
    _totalAmountController.addListener(() => setState(() => _hasChanges = true));
    _instructionsController.addListener(() => setState(() => _hasChanges = true));
  }

  MedicationType _getMedicationTypeFromString(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'tablet':
        return MedicationType.tablet;
      case 'capsule':
        return MedicationType.capsule;
      case 'syrup':
        return MedicationType.syrup;
      case 'drops':
        return MedicationType.drops;
      case 'injection':
        return MedicationType.injection;
      case 'inhaler':
        return MedicationType.inhaler;
      case 'vitamin':
        return MedicationType.vitamin;
      default:
        return MedicationType.tablet;
    }
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
    return Scaffold(
      backgroundColor: ModernAppColors.darkBg,
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: ModernAppColors.backgroundGradient,
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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

                      // Color and Icon Selection
                      _buildSectionTitle('Appearance'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildColorSelector()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildIconSelector()),
                        ],
                      ),

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

                      // Dosage and Total Amount
                      _buildSectionTitle('Dosage & Amount'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _dosageController,
                              hint: 'e.g. 1 tablet',
                              icon: Icons.medication,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _totalAmountController,
                              hint: 'Total amount',
                              icon: Icons.inventory,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Frequency
                      _buildSectionTitle('Frequency'),
                      const SizedBox(height: 12),
                      _buildFrequencySelector(),

                      const SizedBox(height: 24),

                      // Weekly Schedule Toggle
                      _buildWeeklyScheduleToggle(),
                      
                      if (_useWeeklySchedule) ...[
                        const SizedBox(height: 16),
                        _buildWeekDaySelector(),
                      ],

                      const SizedBox(height: 24),

                      // Start Date
                      _buildSectionTitle('Start Date'),
                      const SizedBox(height: 12),
                      _buildDateSelector(),

                      const SizedBox(height: 24),

                      // Instructions
                      _buildSectionTitle('Instructions (Optional)'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _instructionsController,
                        hint: 'e.g. Take with food',
                        icon: Icons.note_alt,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Fixed bottom action buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ModernAppColors.darkBg.withOpacity(0.0),
                    ModernAppColors.darkBg,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSaveButton(context),
                  const SizedBox(height: 12),
                  _buildDeleteButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernAppColors.cardBg.withOpacity(0.9),
            ModernAppColors.cardBg.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ModernAppColors.deepPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ModernAppColors.darkBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ModernAppColors.vibrantCyan.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: ModernAppColors.lightText,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Edit Medication',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ModernAppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: ModernAppColors.lightText,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: MedicationType.values.length,
        itemBuilder: (context, index) {
          final type = MedicationType.values[index];
          final isSelected = _selectedType == type;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type;
                  _dosageController.text = type.defaultDosage;
                  _hasChanges = true;
                });
              },
              child: Container(
                width: 95,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            type.color.withOpacity(0.3),
                            type.color.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : ModernAppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? type.color 
                        : ModernAppColors.mutedText.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: type.color.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type.icon,
                      color: isSelected ? type.color : ModernAppColors.mutedText,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type.displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? type.color : ModernAppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector() {
    final colors = [
      '#FF9F43', '#FFD166', '#06D6A0', '#4FC3F7',
      '#9D84FF', '#FF6B9D', '#FF5252',
    ];

    final currentColor = _selectedColor ?? colors[0];

    return Expanded(
      child: GestureDetector(
        onTap: () => _showColorPicker(colors, currentColor),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ModernAppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: ModernAppColors.vibrantCyan.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ModernAppColors.mutedText,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: parseColor(currentColor),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: parseColor(currentColor).withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(List<String> colors, String currentColor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ModernAppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Color',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ModernAppColors.lightText,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: colors.map((color) {
                  final isSelected = currentColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                        _hasChanges = true;
                      });
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 60 : 50,
                      height: isSelected ? 60 : 50,
                      decoration: BoxDecoration(
                        color: parseColor(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: ModernAppColors.lightText, width: 3)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: parseColor(color).withOpacity(0.5),
                            blurRadius: isSelected ? 16 : 8,
                            spreadRadius: isSelected ? 4 : 0,
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 28)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    final icons = {
      'pill': Icons.medication_rounded,
      'capsule': Icons.medication_liquid_rounded,
      'bottle': Icons.local_drink_rounded,
      'vitamin': Icons.restaurant_rounded,
      'injection': Icons.vaccines_rounded,
      'drops': Icons.water_drop_rounded,
      'syrup': Icons.science_rounded,
      'inhaler': Icons.air_rounded,
    };

    final currentIcon = _selectedIcon ?? 'pill';
    final currentColor = _selectedColor ?? '#FF9F43';

    return Expanded(
      child: GestureDetector(
        onTap: () => _showIconPicker(icons, currentIcon),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ModernAppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: ModernAppColors.vibrantCyan.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Icon',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ModernAppColors.mutedText,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: parseColor(currentColor).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icons[currentIcon],
                  color: parseColor(currentColor),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIconPicker(Map<String, IconData> icons, String currentIcon) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ModernAppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Icon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ModernAppColors.lightText,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: icons.entries.map((entry) {
                  final isSelected = currentIcon == entry.key;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = entry.key;
                        _hasChanges = true;
                      });
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ModernAppColors.vibrantCyan.withOpacity(0.2)
                            : ModernAppColors.darkBg,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: ModernAppColors.vibrantCyan, width: 2)
                            : Border.all(
                                color: ModernAppColors.mutedText.withOpacity(0.2),
                                width: 1,
                              ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: ModernAppColors.vibrantCyan.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        entry.value,
                        color: isSelected
                            ? ModernAppColors.vibrantCyan
                            : ModernAppColors.mutedText,
                        size: 28,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          color: ModernAppColors.lightText,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: ModernAppColors.mutedText.withOpacity(0.6),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            icon,
            color: ModernAppColors.vibrantCyan,
            size: 22,
          ),
          filled: true,
          fillColor: ModernAppColors.cardBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: ModernAppColors.mutedText.withOpacity(0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: ModernAppColors.mutedText.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: ModernAppColors.vibrantCyan,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: ModernAppColors.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: ModernAppColors.error,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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

  Widget _buildFrequencySelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ModernAppColors.vibrantCyan.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFrequencyOption('Morning', Icons.wb_sunny_rounded, _frequency.morning, (val) {
            setState(() {
              _frequency = _frequency.copyWith(morning: val);
              _hasChanges = true;
            });
          }),
          Divider(height: 32, color: ModernAppColors.mutedText.withOpacity(0.1)),
          _buildFrequencyOption('Afternoon', Icons.wb_cloudy_rounded, _frequency.afternoon, (val) {
            setState(() {
              _frequency = _frequency.copyWith(afternoon: val);
              _hasChanges = true;
            });
          }),
          Divider(height: 32, color: ModernAppColors.mutedText.withOpacity(0.1)),
          _buildFrequencyOption('Evening', Icons.nightlight_round, _frequency.evening, (val) {
            setState(() {
              _frequency = _frequency.copyWith(evening: val);
              _hasChanges = true;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(String label, IconData icon, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: value
                ? ModernAppColors.vibrantCyan.withOpacity(0.2)
                : ModernAppColors.darkBg.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: value ? ModernAppColors.vibrantCyan : ModernAppColors.mutedText,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: value ? ModernAppColors.lightText : ModernAppColors.mutedText,
            ),
          ),
        ),
        Transform.scale(
          scale: 0.9,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ModernAppColors.vibrantCyan,
            activeTrackColor: ModernAppColors.vibrantCyan.withOpacity(0.3),
            inactiveThumbColor: ModernAppColors.mutedText,
            inactiveTrackColor: ModernAppColors.darkBg,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyScheduleToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ModernAppColors.vibrantCyan.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _useWeeklySchedule
                  ? ModernAppColors.accentOrange.withOpacity(0.2)
                  : ModernAppColors.darkBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: _useWeeklySchedule ? ModernAppColors.accentOrange : ModernAppColors.mutedText,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Specific Days Only',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ModernAppColors.lightText,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: _useWeeklySchedule,
              onChanged: (val) {
                setState(() {
                  _useWeeklySchedule = val;
                  _hasChanges = true;
                });
              },
              activeColor: ModernAppColors.accentOrange,
              activeTrackColor: ModernAppColors.accentOrange.withOpacity(0.3),
              inactiveThumbColor: ModernAppColors.mutedText,
              inactiveTrackColor: ModernAppColors.darkBg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaySelector() {
    const weekDays = [
      {'name': 'Mon', 'value': 1},
      {'name': 'Tue', 'value': 2},
      {'name': 'Wed', 'value': 3},
      {'name': 'Thu', 'value': 4},
      {'name': 'Fri', 'value': 5},
      {'name': 'Sat', 'value': 6},
      {'name': 'Sun', 'value': 7},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ModernAppColors.vibrantCyan.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
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
                _hasChanges = true;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [ModernAppColors.vibrantCyan, ModernAppColors.deepPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : ModernAppColors.darkBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? ModernAppColors.vibrantCyan
                      : ModernAppColors.mutedText.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: ModernAppColors.vibrantCyan.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  day['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : ModernAppColors.mutedText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: ModernAppColors.vibrantCyan,
                  onPrimary: ModernAppColors.darkBg,
                  surface: ModernAppColors.cardBg,
                  onSurface: ModernAppColors.lightText,
                ),
                dialogBackgroundColor: ModernAppColors.cardBg,
              ),
              child: child!,
            );
          },
        );
        
        if (picked != null && picked != _startDate) {
          setState(() {
            _startDate = picked;
            _hasChanges = true;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ModernAppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: ModernAppColors.vibrantCyan.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ModernAppColors.accentGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: ModernAppColors.accentGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ModernAppColors.lightText,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: ModernAppColors.mutedText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: _hasChanges ? () => _handleSave(context) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: _hasChanges
              ? const LinearGradient(
                  colors: [ModernAppColors.vibrantCyan, ModernAppColors.deepPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : LinearGradient(
                  colors: [
                    ModernAppColors.mutedText.withOpacity(0.3),
                    ModernAppColors.mutedText.withOpacity(0.2),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _hasChanges
              ? [
                  BoxShadow(
                    color: ModernAppColors.vibrantCyan.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: _hasChanges ? Colors.white : ModernAppColors.darkText,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _hasChanges ? Colors.white : ModernAppColors.darkText,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleDelete(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ModernAppColors.error.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: ModernAppColors.error, size: 22),
            SizedBox(width: 10),
            Text(
              'Delete Medication',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ModernAppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (!_frequency.morning && !_frequency.afternoon && !_frequency.evening) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please select at least one time of day',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: ModernAppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ModernAppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const CircularProgressIndicator(
            color: ModernAppColors.vibrantCyan,
          ),
        ),
      ),
    );

    try {
      // Create updated medication
      final updatedMedication = widget.medication.copyWith(
        name: _nameController.text,
        dosage: _dosageController.text,
        instructions: _instructionsController.text,
        startDate: _startDate.toIso8601String(),
        frequency: _frequency,
        type: _selectedType.toFirebaseValue(),
        totalAmount: int.tryParse(_totalAmountController.text),
        color: _selectedColor,
        icon: _selectedIcon,
        daysOfWeek: _useWeeklySchedule ? _selectedWeekDays.toList() : null,
      );

      // Update medication in Firebase
      await context.read<MedicationModel>().updateMedication(updatedMedication);

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close edit screen

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${updatedMedication.name} updated successfully!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: ModernAppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating medication: $e',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: ModernAppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ModernAppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ModernAppColors.error.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: ModernAppColors.error,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Delete Medication',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ModernAppColors.lightText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${widget.medication.name}"?\n\nThis will mark the medication as inactive and stop future reminders.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: ModernAppColors.mutedText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: ModernAppColors.darkBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ModernAppColors.lightText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: ModernAppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ModernAppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const CircularProgressIndicator(
            color: ModernAppColors.vibrantCyan,
          ),
        ),
      ),
    );

    try {
      // Mark medication as inactive
      final inactiveMedication = widget.medication.copyWith(active: false);
      await context.read<MedicationModel>().updateMedication(inactiveMedication);

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close edit screen

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${widget.medication.name} deleted successfully',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: ModernAppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error deleting medication: $e',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: ModernAppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}
