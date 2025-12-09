import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/medication_model.dart';
import 'package:health_care/widgets/medication/day_selector.dart';
import 'package:health_care/widgets/medication/medication_card.dart';
import 'package:health_care/theme/app_theme.dart';

// 📁 lib/screens/medication/medication_home_screen.dart

class MedicationHomeScreen extends StatefulWidget {
  const MedicationHomeScreen({super.key});

  @override
  State<MedicationHomeScreen> createState() => _MedicationHomeScreenState();
}

class _MedicationHomeScreenState extends State<MedicationHomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 20),

            // Day Selector
            DaySelector(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            const SizedBox(height: 24),

            // Medications List
            Expanded(
              child: _buildMedicationsList(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/medication/add');
        },
        backgroundColor: const Color(0xFF9D84FF),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medication',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8DEFF), Color(0xFFF3EFFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF9D84FF),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer<MedicationModel>(
            builder: (context, model, child) {
              final completed = model.getTodayCompletionCount();
              final total = model.getTodayTotalCount();
              return Text(
                '$completed of $total medications taken today',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsList(BuildContext context) {
    return Consumer<MedicationModel>(
      builder: (context, model, child) {
        final medications = model.getMedicationsForDay(_selectedDate);

        if (medications.isEmpty) {
          return _buildEmptyState();
        }

        // Group by category
        final morning = medications
            .where((m) => m.category == MedicationCategory.morning)
            .toList();
        final afternoon = medications
            .where((m) => m.category == MedicationCategory.afternoon)
            .toList();
        final evening = medications
            .where((m) => m.category == MedicationCategory.evening)
            .toList();
        final night = medications
            .where((m) => m.category == MedicationCategory.night)
            .toList();

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            if (morning.isNotEmpty) ...[
              _buildCategoryHeader('Morning', Icons.wb_sunny, const Color(0xFFFFD166)),
              ...morning.map((med) => MedicationCard(
                    medication: med,
                    onTap: () => _navigateToDetail(context, med),
                  )),
              const SizedBox(height: 16),
            ],
            if (afternoon.isNotEmpty) ...[
              _buildCategoryHeader('Afternoon', Icons.wb_sunny_outlined, const Color(0xFF06D6A0)),
              ...afternoon.map((med) => MedicationCard(
                    medication: med,
                    onTap: () => _navigateToDetail(context, med),
                  )),
              const SizedBox(height: 16),
            ],
            if (evening.isNotEmpty) ...[
              _buildCategoryHeader('Evening', Icons.nights_stay_outlined, const Color(0xFF9D84FF)),
              ...evening.map((med) => MedicationCard(
                    medication: med,
                    onTap: () => _navigateToDetail(context, med),
                  )),
              const SizedBox(height: 16),
            ],
            if (night.isNotEmpty) ...[
              _buildCategoryHeader('Night', Icons.dark_mode, const Color(0xFF118AB2)),
              ...night.map((med) => MedicationCard(
                    medication: med,
                    onTap: () => _navigateToDetail(context, med),
                  )),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 80), // Space for FAB
          ],
        );
      },
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFF3EFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_liquid,
              size: 60,
              color: Color(0xFF9D84FF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No medications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first medication',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Medication medication) {
    Navigator.pushNamed(
      context,
      '/medication/detail',
      arguments: medication,
    );
  }
}
