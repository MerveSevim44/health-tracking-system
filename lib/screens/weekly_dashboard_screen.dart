import 'package:flutter/material.dart';
import 'package:health_care/theme/modern_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health_care/services/mood_service.dart';
import 'package:health_care/services/water_service.dart';
import 'package:health_care/services/medication_service.dart';
import 'package:health_care/models/mood_firebase_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 📊 MINOA - Weekly Dashboard (Real Firebase Data Only)

class WeeklyDashboardScreen extends StatefulWidget {
  const WeeklyDashboardScreen({super.key});

  @override
  State<WeeklyDashboardScreen> createState() => _WeeklyDashboardScreenState();
}

class _WeeklyDashboardScreenState extends State<WeeklyDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  String _selectedPeriod = 'Week';
  
  final MoodService _moodService = MoodService();
  final WaterService _waterService = WaterService();
  final MedicationService _medicationService = MedicationService();
  
  List<MoodFirebase> _weekMoods = [];
  Map<String, int> _weekWaterData = {};
  double _medicationAdherence = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadWeeklyData();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _loadWeeklyData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      
      // Load last 7 days of moods
      final moods = await _moodService.getLast7Moods(userId);
      
      // Load water data for last 7 days
      final waterData = <String, int>{};
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final intake = await _waterService.getTotalIntakeForDate(date);
        waterData[dateKey] = intake;
      }
      
      // Calculate medication adherence for the week
      final medications = await _medicationService.getMedications().first;
      final activeMeds = medications.where((m) => m.active).toList();
      if (activeMeds.isNotEmpty) {
        int totalRequired = activeMeds.length * 7; // 7 days
        int totalTaken = 0;
        
        for (var med in activeMeds) {
          for (int i = 0; i < 7; i++) {
            final date = now.subtract(Duration(days: i));
            final intakesMap = await _medicationService.getIntakesForDate(date);
            if (intakesMap.containsKey(med.id)) {
              totalTaken += intakesMap[med.id]!.where((i) => i.taken).length;
            }
          }
        }
        
        _medicationAdherence = totalRequired > 0 ? (totalTaken / totalRequired) * 100 : 0.0;
      }

      if (mounted) {
        setState(() {
          _weekMoods = moods;
          _weekWaterData = waterData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading weekly data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ModernAppColors.darkBg,
        body: Center(
          child: CircularProgressIndicator(
            color: ModernAppColors.vibrantCyan,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ModernAppColors.darkBg,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadWeeklyData,
              color: ModernAppColors.vibrantCyan,
              backgroundColor: ModernAppColors.cardBg,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    
                    // Header
                    _buildHeader(),
                    
                    const SizedBox(height: 25),
                    
                    // Period selector
                    _buildPeriodSelector(),
                    
                    const SizedBox(height: 25),
                    
                    // ✅ REAL DATA: Weekly mood overview
                    _buildWeeklyMoodOverview(),
                    
                    const SizedBox(height: 25),
                    
                    // ✅ REAL DATA: Mood trend chart
                    _buildMoodTrendChart(),
                    
                    const SizedBox(height: 25),
                    
                    // ✅ REAL DATA: Water tracking
                    _buildWaterStats(),
                    
                    const SizedBox(height: 25),
                    
                    // ✅ REAL DATA: Medication adherence
                    _buildMedicationStats(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
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
              bottom: 100 + (_floatController.value * 60),
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ModernAppColors.vibrantCyan.withOpacity(0.2),
                      ModernAppColors.vibrantCyan.withOpacity(0.0),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Analytics',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Track your progress and insights',
          style: TextStyle(
            fontSize: 16,
            color: ModernAppColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Day', 'Week', 'Month'];
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? ModernAppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? ModernAppColors.lightText
                        : ModernAppColors.mutedText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyMoodOverview() {
    if (_weekMoods.isEmpty) {
      return _buildEmptyState('No mood data for this week', Icons.mood_outlined);
    }

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: 6));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Mood Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ModernAppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = weekStart.add(Duration(days: index));
              final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              
              // Find mood for this day
              final dayMood = _weekMoods.firstWhere(
                (m) => m.id == dateKey,
                orElse: () => MoodFirebase(
                  id: dateKey,
                  date: date.toIso8601String(),
                  moodLevel: 0,
                  emotions: [],
                  notes: '',
                  sentimentScore: 0,
                  sentimentMagnitude: 0,
                ),
              );
              
              final hasMood = dayMood.moodLevel > 0;
              final double moodHeight = hasMood ? 35 + (dayMood.moodLevel * 10.0) : 20.0;
              final moodColor = hasMood ? _getMoodColor(dayMood.moodLevel) : ModernAppColors.mutedText.withOpacity(0.3);

              return Column(
                children: [
                  Container(
                    width: 35,
                    height: moodHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          moodColor,
                          moodColor.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[date.weekday - 1],
                    style: const TextStyle(
                      color: ModernAppColors.mutedText,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTrendChart() {
    if (_weekMoods.isEmpty) {
      return _buildEmptyState('No mood trend data', Icons.show_chart);
    }

    // Build spots from real mood data
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: 6));
    final spots = <FlSpot>[];
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final dayMood = _weekMoods.firstWhere(
        (m) => m.id == dateKey,
        orElse: () => MoodFirebase(
          id: dateKey,
          date: date.toIso8601String(),
          moodLevel: 3, // neutral if no data
          emotions: [],
          notes: '',
          sentimentScore: 0,
          sentimentMagnitude: 0,
        ),
      );
      
      spots.add(FlSpot(i.toDouble(), dayMood.moodLevel.toDouble()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood Trend',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ModernAppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: ModernAppColors.mutedText.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Text(
                          days[value.toInt()],
                          style: const TextStyle(
                            color: ModernAppColors.mutedText,
                            fontSize: 12,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 5,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: ModernAppColors.primaryGradient,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: _getMoodColor(spot.y.round()),
                        strokeWidth: 2,
                        strokeColor: ModernAppColors.cardBg,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ModernAppColors.deepPurple.withOpacity(0.3),
                        ModernAppColors.deepPurple.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ NEW: Water Stats Widget (Real Data)
  Widget _buildWaterStats() {
    if (_weekWaterData.isEmpty) {
      return _buildEmptyState('No water data for this week', Icons.water_drop_outlined);
    }

    final totalIntake = _weekWaterData.values.fold<int>(0, (sum, intake) => sum + intake);
    final avgDaily = (totalIntake / 7).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Water Intake',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ModernAppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Total', '${totalIntake}ml', Icons.water_drop, ModernAppColors.vibrantCyan),
              Container(width: 1, height: 40, color: ModernAppColors.mutedText.withOpacity(0.2)),
              _buildStatColumn('Daily Avg', '${avgDaily}ml', Icons.show_chart, ModernAppColors.electricBlue),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ NEW: Medication Stats Widget (Real Data)
  Widget _buildMedicationStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medication Adherence',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ModernAppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weekly Adherence',
                    style: TextStyle(
                      fontSize: 16,
                      color: ModernAppColors.mutedText,
                    ),
                  ),
                  Text(
                    '${_medicationAdherence.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _medicationAdherence >= 80
                          ? ModernAppColors.accentGreen
                          : ModernAppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _medicationAdherence / 100,
                  minHeight: 10,
                  backgroundColor: ModernAppColors.darkText.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(
                    _medicationAdherence >= 80
                        ? ModernAppColors.accentGreen
                        : ModernAppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: ModernAppColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: ModernAppColors.mutedText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: ModernAppColors.mutedText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(int moodLevel) {
    switch (moodLevel) {
      case 5: return ModernAppColors.accentGreen;
      case 4: return ModernAppColors.vibrantCyan;
      case 3: return ModernAppColors.accentYellow;
      case 2: return ModernAppColors.accentOrange;
      case 1: return ModernAppColors.error;
      default: return ModernAppColors.mutedText;
    }
  }

}
