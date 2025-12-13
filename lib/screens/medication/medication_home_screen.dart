import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/screens/medication/medication_detail_enhanced_screen.dart';
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
      
      final allMedications = model.medicationsFirebase
          .where((med) => med.active)
          .toList();
      
      final Map<String, List<MedicationIntake>> intakesMap = {};
      for (final med in allMedications) {
        final intakes = await model.getIntakesForMedicationOnDate(
          medicationId: med.id,
          date: _selectedDate,
        );
        intakesMap[med.id] = intakes;
      }
      
      if (!mounted) return;
      
      setState(() {
        _medications = allMedications;
        _intakesByMedication = intakesMap;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading medications: $e');
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
          const Text(
            'Medications',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: ModernAppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _medications.isEmpty 
                ? 'No medications added yet'
                : '${_medications.length} active medication${_medications.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 16,
              color: ModernAppColors.mutedText,
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

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'pill':
        return Icons.medication_rounded;
      case 'capsule':
        return Icons.medication_liquid_rounded;
      case 'bottle':
        return Icons.local_drink_rounded;
      case 'vitamin':
        return Icons.restaurant_rounded;
      case 'injection':
        return Icons.vaccines_rounded;
      case 'drops':
        return Icons.water_drop_rounded;
      case 'syrup':
        return Icons.science_rounded;
      case 'inhaler':
        return Icons.air_rounded;
      default:
        return Icons.medication_rounded;
    }
  }

  Color _getDefaultColor() {
    return const Color(0xFFFF9F43); // Default orange
  }

  Widget _buildMedicationCard(MedicationFirebase medication, List<MedicationIntake> intakes) {
    // Calculate total doses from frequency
    int totalDoses = 0;
    if (medication.frequency.morning) totalDoses++;
    if (medication.frequency.afternoon) totalDoses++;
    if (medication.frequency.evening) totalDoses++;
    
    final takenDoses = intakes.where((i) => i.taken).length;
    final progress = totalDoses > 0 ? takenDoses / totalDoses : 0.0;
    
    final iconData = _getIconForType(medication.type);
    final cardColor = _getDefaultColor(); // Can be extended to use medication.color if stored

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicationDetailEnhancedScreen(
              medication: medication,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ModernAppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cardColor.withOpacity(0.3),
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
                    color: cardColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: cardColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ModernAppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medication.dosage} • $totalDoses times/day',
                        style: const TextStyle(
                          fontSize: 13,
                          color: ModernAppColors.mutedText,
                        ),
                      ),
                      if (medication.totalAmount != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${medication.totalAmount} doses remaining',
                          style: TextStyle(
                            fontSize: 11,
                            color: cardColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
                      : cardColor,
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$takenDoses of $totalDoses doses taken',
                  style: TextStyle(
                    fontSize: 12,
                    color: progress == 1.0 
                        ? ModernAppColors.accentGreen 
                        : ModernAppColors.mutedText,
                  ),
                ),
                if (medication.endDate != null)
                  Text(
                    'Until ${_formatEndDate(medication.endDate!)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: ModernAppColors.mutedText,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatEndDate(String endDateStr) {
    try {
      final endDate = DateTime.parse(endDateStr);
      final now = DateTime.now();
      final difference = endDate.difference(now).inDays;
      
      if (difference < 0) {
        return 'Expired';
      } else if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference < 7) {
        return '$difference days';
      } else if (difference < 30) {
        final weeks = (difference / 7).ceil();
        return '$weeks weeks';
      } else {
        final months = (difference / 30).ceil();
        return '$months months';
      }
    } catch (e) {
      return '';
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
