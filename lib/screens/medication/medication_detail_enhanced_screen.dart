import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/models/medication_firebase_model.dart';
import 'package:health_care/theme/modern_colors.dart';
import 'dart:ui';

class MedicationDetailEnhancedScreen extends StatefulWidget {
  final MedicationFirebase medication;

  const MedicationDetailEnhancedScreen({
    super.key,
    required this.medication,
  });

  @override
  State<MedicationDetailEnhancedScreen> createState() => _MedicationDetailEnhancedScreenState();
}

class _MedicationDetailEnhancedScreenState extends State<MedicationDetailEnhancedScreen> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List<MedicationIntake> _todayIntakes = [];
  bool _isLoading = true;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadData();
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
      
      final intakes = await model.getIntakesForMedicationOnDate(
        medicationId: widget.medication.id,
        date: _selectedDate,
      );
      
      setState(() {
        _todayIntakes = intakes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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

  Color _getMedicationColor() {
    return const Color(0xFFFF9F43); // Default orange, can be extended
  }

  @override
  Widget build(BuildContext context) {
    final medicationColor = _getMedicationColor();
    final iconData = _getIconForType(widget.medication.type);
    
    return Scaffold(
      backgroundColor: ModernAppColors.darkBg,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(medicationColor),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ModernAppColors.vibrantCyan,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Medication Info Card
                              _buildInfoCard(iconData, medicationColor),
                              const SizedBox(height: 24),
                              
                              // Frequency Display
                              _buildFrequencyDisplay(),
                              const SizedBox(height: 24),
                              
                              // Today's Intakes
                              _buildTodayIntakes(medicationColor),
                              const SizedBox(height: 24),
                              
                              // Statistics
                              _buildStatistics(medicationColor),
                              const SizedBox(height: 24),
                              
                              // Action Buttons
                              _buildActionButtons(medicationColor),
                              
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Color color) {
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
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.0),
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
    return Padding(
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
          const Expanded(
            child: Center(
              child: Text(
                'Medication Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ModernAppColors.lightText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData iconData, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  iconData,
                  color: ModernAppColors.lightText,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.medication.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ModernAppColors.lightText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.medication.dosage,
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (widget.medication.instructions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ModernAppColors.cardBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.medication.instructions,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ModernAppColors.lightText,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (widget.medication.totalAmount != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.inventory_rounded, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total: ${widget.medication.totalAmount} doses',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ModernAppColors.mutedText,
                  ),
                ),
              ],
            ),
          ],
          
          if (widget.medication.endDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event_rounded, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Until: ${_formatEndDate(widget.medication.endDate!)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ModernAppColors.mutedText,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFrequencyDisplay() {
    final freq = widget.medication.frequency;
    final times = <Map<String, dynamic>>[];
    
    if (freq.morning) {
      times.add({'icon': Icons.wb_sunny_rounded, 'label': 'Morning', 'color': const Color(0xFFFFD93D)});
    }
    if (freq.afternoon) {
      times.add({'icon': Icons.wb_twilight_rounded, 'label': 'Afternoon', 'color': const Color(0xFFFF9F43)});
    }
    if (freq.evening) {
      times.add({'icon': Icons.nightlight_round, 'label': 'Evening', 'color': const Color(0xFF9D84FF)});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: times.map((time) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ModernAppColors.cardBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: (time['color'] as Color).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    time['icon'] as IconData,
                    color: time['color'] as Color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time['label'] as String,
                    style: const TextStyle(
                      color: ModernAppColors.lightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTodayIntakes(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Doses",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 12),
        if (_todayIntakes.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ModernAppColors.cardBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'No doses scheduled for today',
                style: TextStyle(color: ModernAppColors.mutedText),
              ),
            ),
          )
        else
          ..._todayIntakes.map((intake) => _buildIntakeCard(intake, color)),
      ],
    );
  }

  Widget _buildIntakeCard(MedicationIntake intake, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: intake.taken
              ? ModernAppColors.accentGreen
              : color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: intake.taken
                  ? ModernAppColors.accentGreen.withOpacity(0.2)
                  : color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              intake.taken ? Icons.check_circle_rounded : Icons.schedule_rounded,
              color: intake.taken ? ModernAppColors.accentGreen : color,
              size: 24,
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
                    color: ModernAppColors.lightText,
                  ),
                ),
                if (intake.plannedDose != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    intake.plannedDose!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ModernAppColors.mutedText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: intake.taken,
            activeColor: ModernAppColors.accentGreen,
            inactiveThumbColor: ModernAppColors.mutedText,
            inactiveTrackColor: ModernAppColors.darkBg,
            onChanged: (value) => _toggleIntake(intake, value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(Color color) {
    final takenCount = _todayIntakes.where((i) => i.taken).length;
    final totalCount = _todayIntakes.length;
    final completionRate = totalCount > 0 ? (takenCount / totalCount * 100) : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ModernAppColors.lightText,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Taken today', '$takenCount / $totalCount', color),
          const SizedBox(height: 12),
          _buildStatRow('Completion rate', '${completionRate.toStringAsFixed(0)}%', color),
          if (widget.medication.totalAmount != null) ...[
            const SizedBox(height: 12),
            _buildStatRow('Remaining', '${widget.medication.totalAmount} doses', color),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: ModernAppColors.mutedText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color color) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: ModernAppColors.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: TextButton.icon(
              onPressed: () => _showDeleteConfirmation(),
              icon: const Icon(Icons.delete_outline_rounded, color: ModernAppColors.error),
              label: const Text(
                'Delete',
                style: TextStyle(
                  color: ModernAppColors.error,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () => _showEditDialog(),
              icon: const Icon(Icons.edit_rounded, color: ModernAppColors.lightText),
              label: const Text(
                'Edit',
                style: TextStyle(
                  color: ModernAppColors.lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
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
      return 'Unknown';
    }
  }

  Future<void> _toggleIntake(MedicationIntake intake, bool value) async {
    try {
      await context.read<MedicationModel>().updateIntakeStatus(
            medicationId: widget.medication.id,
            intakeId: intake.id,
            taken: value,
          );
      
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? '✓ Dose marked as taken' : 'Dose unmarked'),
            backgroundColor: value ? ModernAppColors.accentGreen : ModernAppColors.mutedText,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(20),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ModernAppColors.error,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(20),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernAppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Medication',
          style: TextStyle(color: ModernAppColors.lightText),
        ),
        content: const Text(
          'Medication editing feature coming soon.',
          style: TextStyle(color: ModernAppColors.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: ModernAppColors.vibrantCyan),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernAppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Medication',
          style: TextStyle(color: ModernAppColors.lightText),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.medication.name}"? This action cannot be undone.',
          style: const TextStyle(color: ModernAppColors.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ModernAppColors.mutedText),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _deleteMedication();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: ModernAppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMedication() async {
    try {
      await context.read<MedicationModel>().deleteMedication(widget.medication.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Medication deleted'),
            backgroundColor: ModernAppColors.accentGreen,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context); // Go back to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting medication: $e'),
            backgroundColor: ModernAppColors.error,
          ),
        );
      }
    }
  }
}
