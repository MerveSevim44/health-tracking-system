import 'package:flutter/material.dart';
import 'package:health_care/theme/modern_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyDashboardScreen extends StatefulWidget {
  const WeeklyDashboardScreen({super.key});

  @override
  State<WeeklyDashboardScreen> createState() => _WeeklyDashboardScreenState();
}

class _WeeklyDashboardScreenState extends State<WeeklyDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  String _selectedPeriod = 'Week';

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
    _floatController.dispose();
    super.dispose();
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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
                  
                  // Weekly mood overview
                  _buildWeeklyMoodOverview(),
                  
                  const SizedBox(height: 25),
                  
                  // Mood trend chart
                  _buildMoodTrendChart(),
                  
                  const SizedBox(height: 25),
                  
                  // Activity stats
                  _buildActivityStats(),
                  
                  const SizedBox(height: 20),
                ],
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
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final moods = [0.8, 0.6, 0.7, 0.9, 0.5, 0.8, 0.7];
    final colors = [
      ModernAppColors.accentGreen,
      ModernAppColors.accentOrange,
      ModernAppColors.vibrantCyan,
      ModernAppColors.accentPink,
      ModernAppColors.accentYellow,
      ModernAppColors.deepPurple,
      ModernAppColors.accentGreen,
    ];

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
              return Column(
                children: [
                  Container(
                    width: 35,
                    height: 35 + (moods[index] * 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors[index],
                          colors[index].withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
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
                horizontalInterval: 2,
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
              maxY: 10,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 7),
                    FlSpot(1, 5),
                    FlSpot(2, 6),
                    FlSpot(3, 8),
                    FlSpot(4, 4),
                    FlSpot(5, 7),
                    FlSpot(6, 6),
                  ],
                  isCurved: true,
                  gradient: ModernAppColors.primaryGradient,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: ModernAppColors.vibrantCyan,
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

  Widget _buildActivityStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Mood Logs',
                '28',
                Icons.mood_rounded,
                ModernAppColors.accentPink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                'Water',
                '48',
                Icons.water_drop_rounded,
                ModernAppColors.vibrantCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Medications',
                '21',
                Icons.medication_rounded,
                ModernAppColors.accentOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                'Exercises',
                '14',
                Icons.self_improvement_rounded,
                ModernAppColors.accentGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: ModernAppColors.lightText,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: ModernAppColors.mutedText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
