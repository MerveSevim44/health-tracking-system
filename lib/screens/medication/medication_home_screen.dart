import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/screens/medication/edit_medication_screen.dart';
import 'package:health_care/theme/modern_colors.dart';

class MedicationHomeScreen extends StatefulWidget {
  const MedicationHomeScreen({super.key});

  @override
  State<MedicationHomeScreen> createState() => _MedicationHomeScreenState();
}

class _MedicationHomeScreenState extends State<MedicationHomeScreen> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<MedicationFirebase> _medications = [];
  Map<String, List<MedicationIntake>> _intakesByMedication = {};
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final model = context.read<MedicationModel>();
      
      if (model.medicationsFirebase.isEmpty) {
        model.initialize();
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      debugPrint('[LOAD DATA] Loading medications for date: ${_selectedDate}');
      
      // Get all medications and filter by due date
      final allMedications = model.medicationsFirebase
          .where((med) => med.isMedicationDueOnDate(_selectedDate))
          .toList();
      
      debugPrint('[LOAD DATA] Found ${allMedications.length} medications due on ${_selectedDate}');
      
      // Load intakes for each medication
      final Map<String, List<MedicationIntake>> intakesMap = {};
      for (final med in allMedications) {
        final intakes = await model.getIntakesForMedicationOnDate(
          medicationId: med.id,
          date: _selectedDate,
        );
        intakesMap[med.id] = intakes;
        debugPrint('[LOAD DATA] Med ${med.name}: ${intakes.length} intakes');
      }
      
      if (!mounted) return;
      
      setState(() {
        _medications = allMedications;
        _intakesByMedication = intakesMap;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[LOAD DATA] Error loading medications: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernAppColors.darkBg,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildModernDaySelector(),
                const SizedBox(height: 24),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ModernAppColors.vibrantCyan,
                          ),
                        )
                      : _buildMedicationsList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddButton(context),
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
              top: 150 + (_floatController.value * 50),
              right: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ModernAppColors.accentOrange.withOpacity(0.2),
                      ModernAppColors.accentOrange.withOpacity(0.0),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button with title
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: ModernAppColors.lightText),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Text(
                'Medications',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ModernAppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 56), // Align with title after back button
            child: Text(
              _medications.isEmpty 
                  ? 'No medications added yet'
                  : '${_medications.length} active medication${_medications.length != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 16,
                color: ModernAppColors.mutedText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDaySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
              _loadData();
            },
            icon: const Icon(Icons.chevron_left, color: ModernAppColors.lightText),
          ),
          GestureDetector(
            onTap: _showCalendarPicker,
            child: Row(
              children: [
                Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ModernAppColors.lightText,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_today_rounded,
                  color: ModernAppColors.vibrantCyan,
                  size: 20,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
              _loadData();
            },
            icon: const Icon(Icons.chevron_right, color: ModernAppColors.lightText),
          ),
        ],
      ),
    );
  }

  Future<void> _showCalendarPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Yesterday';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day + 1) {
      return 'Tomorrow';
    }
    
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildMedicationsList() {
    if (_medications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final medication = _medications[index];
        final intakes = _intakesByMedication[medication.id] ?? [];
        
        return _buildMedicationCard(medication, intakes);
      },
    );
  }

  Widget _buildMedicationCard(MedicationFirebase medication, List<MedicationIntake> intakes) {
    final dateKey = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final slots = medication.getTimeSlots();
    
    // Create intake map by slot
    final Map<String, bool> intakeStatus = {};
    for (final slot in slots) {
      final intakeKey = '${dateKey}_$slot';
      final intake = intakes.firstWhere(
        (i) => i.id == intakeKey || i.period == slot,
        orElse: () => MedicationIntake(id: '', medicationId: medication.id, date: dateKey, taken: false),
      );
      intakeStatus[slot] = intake.taken;
    }
    
    final takenCount = intakeStatus.values.where((t) => t).length;
    final totalCount = slots.length;
    final progress = totalCount > 0 ? takenCount / totalCount : 0.0;
    
    // Use medication's color and icon
    final medColor = medication.displayColor;
    final medIcon = medication.displayIcon;
    
    debugPrint('[CARD] Med: ${medication.name}, Color: ${medication.color}, Icon: ${medication.icon}');

    return GestureDetector(
      onTap: () => _navigateToEdit(medication),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ModernAppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: medColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: medColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    medIcon,
                    color: medColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ModernAppColors.lightText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medication.dosage} • ${slots.length} times/day',
                        style: const TextStyle(
                          fontSize: 13,
                          color: ModernAppColors.mutedText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.edit_outlined,
                  color: ModernAppColors.mutedText,
                  size: 20,
                ),
              ],
            ),
          
          const SizedBox(height: 15),
          
          // Time slots with checkboxes
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((slot) {
              final isTaken = intakeStatus[slot] ?? false;
              return _buildSlotChip(medication, slot, isTaken);
            }).toList(),
          ),
          
          const SizedBox(height: 15),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: ModernAppColors.darkBg,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 
                    ? ModernAppColors.accentGreen 
                    : medColor,
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          Text(
            '$takenCount of $totalCount doses taken',
            style: TextStyle(
              fontSize: 12,
              color: progress == 1.0 
                  ? ModernAppColors.accentGreen 
                  : ModernAppColors.mutedText,
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _navigateToEdit(MedicationFirebase medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicationScreen(medication: medication),
      ),
    ).then((_) => _loadData());
  }
  
  Widget _buildSlotChip(MedicationFirebase medication, String slot, bool isTaken) {
    final slotColor = slot == 'morning' ? const Color(0xFFFFD166) : 
                      slot == 'afternoon' ? const Color(0xFF06D6A0) : 
                      const Color(0xFF9D84FF);
    
    return GestureDetector(
      onTap: () => _toggleSlotIntake(medication, slot),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isTaken ? slotColor.withOpacity(0.3) : ModernAppColors.darkBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isTaken ? slotColor : ModernAppColors.mutedText.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTaken ? Icons.check_circle : Icons.circle_outlined,
              color: isTaken ? slotColor : ModernAppColors.mutedText,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              slot.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isTaken ? slotColor : ModernAppColors.mutedText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _toggleSlotIntake(MedicationFirebase medication, String slot) async {
    try {
      final model = context.read<MedicationModel>();
      await model.toggleMedicationIntake(
        medicationId: medication.id,
        date: _selectedDate,
        slot: slot,
      );
      
      debugPrint('[TOGGLE] Toggled ${medication.name} $slot on ${_selectedDate}');
      
      // Reload data
      await _loadData();
    } catch (e) {
      debugPrint('[TOGGLE] Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating medication: $e'),
          backgroundColor: ModernAppColors.error,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: ModernAppColors.accentOrange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_rounded,
              size: 50,
              color: ModernAppColors.accentOrange,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No medications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ModernAppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first medication',
            style: TextStyle(
              fontSize: 14,
              color: ModernAppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: ModernAppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          ModernAppColors.primaryShadow(opacity: 0.4),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/medication/add').then((_) => _loadData());
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add_rounded,
          color: ModernAppColors.lightText,
          size: 32,
        ),
      ),
    );
  }
}
