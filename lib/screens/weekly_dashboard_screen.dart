import 'package:flutter/material.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:health_care/widgets/pastel_components.dart';
import 'package:health_care/widgets/mood_blob.dart';
import 'package:fl_chart/fl_chart.dart';

// 📁 lib/screens/weekly_dashboard_screen.dart

class WeeklyDashboardScreen extends StatelessWidget {
  const WeeklyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        colors: const [
          AppColors.gradientMintStart,
          AppColors.gradientMintEnd,
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: 24),

                // Time filter (Month/Week/Day)
                _buildTimeFilter(),

                const SizedBox(height: 24),

                // Weekly mood circles
                _buildWeeklyMoodCircles(),

                const SizedBox(height: 32),

                // Mood trend chart
                _buildMoodTrendCard(),

                const SizedBox(height: 20),

                // Stress level chart
                _buildStressLevelCard(),

                const SizedBox(height: 32),

                // Exercises section
                const Text(
                  'Exercises for you',
                  style: AppTextStyles.headlineMedium,
                ),

                const SizedBox(height: 16),

                _buildExerciseCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dear Alice,',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'good morning',
              style: AppTextStyles.headlineLarge,
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.textLight.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFilter() {
    return Row(
      children: [
        _buildFilterChip('Month', false),
        const SizedBox(width: 8),
        _buildFilterChip('Week', true),
        const SizedBox(width: 8),
        _buildFilterChip('Day', false),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.textDark : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? Colors.white : AppColors.textDark,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildWeeklyMoodCircles() {
    final weekData = [
      {'day': 'M', 'score': 12},
      {'day': 'T', 'score': 13},
      {'day': 'W', 'score': 16},
      {'day': 'T', 'score': 10},
      {'day': 'F', 'score': 14},
      {'day': 'S', 'score': 15},
      {'day': 'S', 'score': 11},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekData.map((data) {
        return WeeklyMoodCircle(
          day: data['day'] as String,
          moodScore: data['score'] as int,
          isSelected: data['day'] == 'T',
        );
      }).toList(),
    );
  }

  Widget _buildMoodTrendCard() {
    return PastelCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last week',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mood unstable',
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pastelPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Edit',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.moodAnxious,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 2),
                      FlSpot(2, 4),
                      FlSpot(3, 2.5),
                      FlSpot(4, 3.5),
                      FlSpot(5, 4),
                      FlSpot(6, 3),
                    ],
                    isCurved: true,
                    color: AppColors.moodCalm,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.moodCalm.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average stress level',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '67% in a week',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              SizedBox(
                width: 80,
                height: 40,
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                          toY: 5,
                          color: AppColors.pastelPink,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                          toY: 7,
                          color: AppColors.moodHappy,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(
                          toY: 4,
                          color: AppColors.pastelMint,
                          width: 8,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStressLevelCard() {
    return PastelCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stress Peaks',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.pastelPink,
                        AppColors.moodHappy,
                        AppColors.pastelMint,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildLegendItem(AppColors.pastelPink, 'Core'),
                    const SizedBox(width: 16),
                    _buildLegendItem(AppColors.moodHappy, 'REM'),
                    const SizedBox(width: 16),
                    _buildLegendItem(AppColors.pastelMint, 'Post-REM'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard() {
    return ExerciseCard(
      title: 'Relieve stress',
      subtitle: 'Breathing practice',
      duration: '15 min',
      backgroundColor: AppColors.pastelPink,
      illustration: const MoodBlob(
        size: 60,
        color: AppColors.moodAnxious,
        expression: MoodExpression.calm,
      ),
      onTap: () {},
    );
  }
}
