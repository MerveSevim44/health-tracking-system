import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/widgets/medication/day_selector.dart';
import 'package:health_care/widgets/medication/medication_intake_card.dart';
import 'package:health_care/screens/medication/medication_detail_enhanced_screen.dart';
import 'package:health_care/theme/app_theme.dart';

// 📁 lib/screens/medication/medication_home_screen.dart

class MedicationHomeScreen extends StatefulWidget {
  const MedicationHomeScreen({super.key});

  @override
  State<MedicationHomeScreen> createState() => _MedicationHomeScreenState();
}

class _MedicationHomeScreenState extends State<MedicationHomeScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<MedicationFirebase> _medications = [];
  Map<String, List<MedicationIntake>> _intakesByMedication = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final model = context.read<MedicationModel>();
      
      // Ensure model is initialized
      if (model.medicationsFirebase.isEmpty) {
        model.initialize();
        // Wait a bit for Firebase to load
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      final allMedications = model.medicationsFirebase
          .where((med) => med.active)
          .toList();
      
      // Load intakes for each medication on selected date
      final Map<String, List<MedicationIntake>> intakesMap = {};
      for (final med in allMedications) {
        final intakes = await model.getIntakesForMedicationOnDate(
          medicationId: med.id,
          date: _selectedDate,
        );
        // Store intakes even if empty - we want to show all medications
        intakesMap[med.id] = intakes;
      }
      
      setState(() {
        _medications = allMedications;
        _intakesByMedication = intakesMap;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading medications: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            DaySelector(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
                _loadData();
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMedicationsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/medication/add');
          _loadData();
        },
        backgroundColor: const Color(0xFF9D84FF),
        elevation: 6,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Medication',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final totalIntakes = _intakesByMedication.values.fold<int>(
      0,
      (sum, intakes) => sum + intakes.length,
    );
    final takenIntakes = _intakesByMedication.values.fold<int>(
      0,
      (sum, intakes) => sum + intakes.where((i) => i.taken).length,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9D84FF).withValues(alpha: 0.1),
            const Color(0xFFB8A4FF).withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medications',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Color(0xFF06D6A0),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$takenIntakes/$totalIntakes',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Track your daily medication schedule',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsList() {
    if (_medications.isEmpty) {
      return _buildEmptyState();
    }

    // Group by period - show all medications with their frequency
    final Map<String, List<MapEntry<MedicationFirebase, MedicationIntake?>>> groupedByPeriod = {
      'morning': [],
      'afternoon': [],
      'evening': [],
    };

    for (final med in _medications) {
      final intakes = _intakesByMedication[med.id] ?? [];
      
      // If medication has intakes for this date, show them
      if (intakes.isNotEmpty) {
        for (final intake in intakes) {
          final period = intake.period ?? 'morning';
          groupedByPeriod[period]?.add(MapEntry(med, intake));
        }
      } else {
        // No intakes yet - show based on frequency
        if (med.frequency.morning) {
          groupedByPeriod['morning']?.add(MapEntry(med, null));
        }
        if (med.frequency.afternoon) {
          groupedByPeriod['afternoon']?.add(MapEntry(med, null));
        }
        if (med.frequency.evening) {
          groupedByPeriod['evening']?.add(MapEntry(med, null));
        }
      }
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (groupedByPeriod['morning']!.isNotEmpty) ...[
          _buildCategoryHeader('Morning', Icons.wb_sunny, const Color(0xFFFFD166)),
          ...groupedByPeriod['morning']!.map((entry) => _buildIntakeCard(entry.key, entry.value, 'morning')),
          const SizedBox(height: 8),
        ],
        if (groupedByPeriod['afternoon']!.isNotEmpty) ...[
          _buildCategoryHeader('Afternoon', Icons.wb_sunny_outlined, const Color(0xFF06D6A0)),
          ...groupedByPeriod['afternoon']!.map((entry) => _buildIntakeCard(entry.key, entry.value, 'afternoon')),
          const SizedBox(height: 8),
        ],
        if (groupedByPeriod['evening']!.isNotEmpty) ...[
          _buildCategoryHeader('Evening', Icons.nights_stay_outlined, const Color(0xFF9D84FF)),
          ...groupedByPeriod['evening']!.map((entry) => _buildIntakeCard(entry.key, entry.value, 'evening')),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildIntakeCard(MedicationFirebase medication, MedicationIntake? intake, String period) {
    return MedicationIntakeCard(
      medication: medication,
      intake: intake,
      period: period,
      onTap: () => _navigateToDetail(medication),
      onCheck: intake != null ? () => _toggleIntake(medication.id, intake) : null,
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF9D84FF).withValues(alpha: 0.2),
                    const Color(0xFFB8A4FF).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9D84FF).withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 80,
                color: Color(0xFF9D84FF),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No medications scheduled',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Add your first medication to start tracking',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(MedicationFirebase medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationDetailEnhancedScreen(
          medication: medication,
        ),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _toggleIntake(String medicationId, MedicationIntake intake) async {
    try {
      await context.read<MedicationModel>().updateIntakeStatus(
            medicationId: medicationId,
            intakeId: intake.id,
            taken: !intake.taken,
          );
      
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  intake.taken ? Icons.undo : Icons.check_circle,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(intake.taken ? 'Marked as not taken' : 'Marked as taken'),
              ],
            ),
            backgroundColor: intake.taken ? Colors.grey : const Color(0xFF06D6A0),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
