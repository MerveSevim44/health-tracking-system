// 📁 lib/screens/medication/medication_detail_enhanced_screen.dart
// Enhanced detail screen with intake tracking and calendar

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/models/medication_type_config.dart';
import 'package:health_care/widgets/medication/medication_intake_calendar.dart';
import 'package:health_care/theme/app_theme.dart';

class MedicationDetailEnhancedScreen extends StatefulWidget {
  final MedicationFirebase medication;

  const MedicationDetailEnhancedScreen({
    super.key,
    required this.medication,
  });

  @override
  State<MedicationDetailEnhancedScreen> createState() => _MedicationDetailEnhancedScreenState();
}

class _MedicationDetailEnhancedScreenState extends State<MedicationDetailEnhancedScreen> {
  DateTime _selectedDate = DateTime.now();
  List<MedicationIntake> _todayIntakes = [];
  Map<DateTime, List<MedicationIntake>> _allIntakes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final model = context.read<MedicationModel>();
      
      // Load today's intakes
      final intakes = await model.getIntakesForMedicationOnDate(
        medicationId: widget.medication.id,
        date: _selectedDate,
      );
      
      // Load all intakes for calendar (simplified - could be optimized)
      // In production, you'd want to load intakes for visible month only
      
      setState(() {
        _todayIntakes = intakes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = MedicationTypeExtension.fromFirebaseValue(widget.medication.type);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Medication Info Card
                          _buildInfoCard(type),
                          const SizedBox(height: 24),
                          
                          // Today's Intakes
                          _buildTodayIntakes(),
                          const SizedBox(height: 24),
                          
                          // Calendar (if intakes exist)
                          if (_allIntakes.isNotEmpty) ...[
                            _buildCalendarSection(),
                            const SizedBox(height: 24),
                          ],
                          
                          // Statistics
                          _buildStatistics(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context),
        backgroundColor: const Color(0xFF9D84FF),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Düzenle',
          style: TextStyle(color: Colors.white),
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
              child: const Icon(Icons.arrow_back, color: AppColors.textDark),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'İlaç Detayları',
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

  Widget _buildInfoCard(MedicationType? type) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (type?.color ?? const Color(0xFF9D84FF)).withValues(alpha: 0.15),
            (type?.color ?? const Color(0xFF9D84FF)).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: type?.color ?? const Color(0xFF9D84FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  type?.icon ?? Icons.medication,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.medication.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type?.displayName ?? 'Medication',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Dosage', widget.medication.dosage),
          if (widget.medication.instructions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Instructions', widget.medication.instructions),
          ],
          const SizedBox(height: 12),
          _buildInfoRow('Frequency', _getFrequencyText()),
          if (widget.medication.totalAmount != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Total Amount', '${widget.medication.totalAmount}'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  String _getFrequencyText() {
    final freq = widget.medication.frequency;
    final times = <String>[];
    if (freq.morning) times.add('Morning');
    if (freq.afternoon) times.add('Afternoon');
    if (freq.evening) times.add('Evening');
    return times.isEmpty ? 'Not specified' : times.join(', ');
  }

  Widget _buildTodayIntakes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        if (_todayIntakes.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'No schedule for today',
                style: TextStyle(color: AppColors.textLight),
              ),
            ),
          )
        else
          ..._todayIntakes.map((intake) => _buildIntakeCard(intake)),
      ],
    );
  }

  Widget _buildIntakeCard(MedicationIntake intake) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: intake.taken
              ? const Color(0xFF06D6A0)
              : const Color(0xFFE8E8E8),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: intake.taken
                  ? const Color(0xFF06D6A0).withValues(alpha: 0.15)
                  : const Color(0xFFFFD166).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              intake.taken ? Icons.check_circle : Icons.schedule,
              color: intake.taken
                  ? const Color(0xFF06D6A0)
                  : const Color(0xFFFFD166),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intake.plannedTime ?? 'Time not specified',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                if (intake.plannedDose != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    intake.plannedDose!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
                if (intake.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    intake.notes,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: intake.taken,
            activeColor: const Color(0xFF06D6A0),
            onChanged: (value) => _toggleIntake(intake, value),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calendar View',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        MedicationIntakeCalendar(
          medicationId: widget.medication.id,
          intakesByDate: _allIntakes,
          onDateTap: (date) {
            setState(() => _selectedDate = date);
            _loadData();
          },
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final takenCount = _todayIntakes.where((i) => i.taken).length;
    final totalCount = _todayIntakes.length;
    final completionRate = totalCount > 0 ? (takenCount / totalCount * 100) : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Taken today', '$takenCount / $totalCount'),
          const SizedBox(height: 12),
          _buildStatRow('Completion rate', '${completionRate.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textLight,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9D84FF),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleIntake(MedicationIntake intake, bool value) async {
    try {
      await context.read<MedicationModel>().updateIntakeStatus(
            medicationId: widget.medication.id,
            intakeId: intake.id,
            taken: value,
          );
      
      // Reload data
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? '✓ Intake recorded' : 'Intake undone'),
            backgroundColor: value ? const Color(0xFF06D6A0) : Colors.grey,
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

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit'),
        content: const Text('Medication editing feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
