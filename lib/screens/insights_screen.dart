import 'package:flutter/material.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:health_care/widgets/pastel_components.dart';
import 'package:health_care/widgets/mood_blob.dart';
import 'package:fl_chart/fl_chart.dart';

// 📁 lib/screens/insights_screen.dart

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        colors: const [
          AppColors.accent,
          AppColors.secondary,
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),

                const SizedBox(height: 32),

                // Alert section
                _buildAlertSection(),

                const SizedBox(height: 24),

                // Mood trend chart
                _buildMoodTrendChart(),

                const SizedBox(height: 32),

                // Tests section
                const Text(
                  'Tests to understand the reasons',
                  style: AppTextStyles.headlineMedium,
                ),

                const SizedBox(height: 16),

                _buildTestCard(
                  title: 'The balance\nof life today',
                  duration: '15 min',
                  backgroundColor: AppColors.secondary.withOpacity(0.2),
                  blob: const MoodBlob(
                    size: 80,
                    color: AppColors.emotionCalm,
                    expression: MoodExpression.happy,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildSmallTestCard(
                        title: 'Your source\nof negativity',
                        duration: '30 min',
                        backgroundColor: AppColors.info.withOpacity(0.2),
                        blob: const MoodBlob(
                          size: 60,
                          color: AppColors.emotionSad,
                          expression: MoodExpression.sad,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallTestCard(
                        title: 'Triggers\nof bad moods',
                        duration: '20 min',
                        backgroundColor: AppColors.warning.withOpacity(0.2),
                        blob: const MoodBlob(
                          size: 60,
                          color: AppColors.emotionHappy,
                          expression: MoodExpression.anxious,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
          color: AppColors.lightTextPrimary,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
          color: AppColors.lightTextPrimary,
        ),
      ],
    );
  }

  Widget _buildAlertSection() {
    return PastelCard(
      backgroundColor: Colors.white.withValues(alpha: 0.7),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your condition\nhas worsened recently',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Mood over the last week',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrendChart() {
    return PastelCard(
      backgroundColor: Colors.white.withValues(alpha: 0.7),
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 150,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 4),
                  FlSpot(1, 3.5),
                  FlSpot(2, 4.5),
                  FlSpot(3, 3),
                  FlSpot(4, 3.8),
                  FlSpot(5, 2.5),
                  FlSpot(6, 2),
                ],
                isCurved: true,
                color: const Color(0xFF9D7FEA),
                barWidth: 4,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF9D7FEA).withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard({
    required String title,
    required String duration,
    required Color backgroundColor,
    required Widget blob,
  }) {
    return PastelCard(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headlineMedium.copyWith(
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 16,
                      color: AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.lightTextPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          blob,
        ],
      ),
    );
  }

  Widget _buildSmallTestCard({
    required String title,
    required String duration,
    required Color backgroundColor,
    required Widget blob,
  }) {
    return PastelCard(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          blob,
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 14,
                color: AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                duration,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
