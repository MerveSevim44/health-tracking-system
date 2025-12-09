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
          AppColors.gradientLavenderStart,
          AppColors.gradientLavenderEnd,
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
                  backgroundColor: AppColors.pastelMint,
                  blob: const MoodBlob(
                    size: 80,
                    color: AppColors.moodCalm,
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
                        backgroundColor: AppColors.pastelBlue,
                        blob: const MoodBlob(
                          size: 60,
                          color: AppColors.moodSad,
                          expression: MoodExpression.sad,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallTestCard(
                        title: 'Triggers\nof bad moods',
                        duration: '20 min',
                        backgroundColor: AppColors.pastelPeach,
                        blob: const MoodBlob(
                          size: 60,
                          color: AppColors.moodHappy,
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
          color: AppColors.textDark,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
          color: AppColors.textDark,
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
              color: AppColors.textLight,
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
                      color: AppColors.textMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.textDark,
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
                color: AppColors.textMedium,
              ),
              const SizedBox(width: 4),
              Text(
                duration,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textDark,
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

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textLight.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(Icons.home_outlined, true),
              _buildNavIcon(Icons.edit_note_outlined, false),
              _buildNavIcon(Icons.chat_bubble_outline, false),
              _buildNavIcon(Icons.person_outline, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isSelected) {
    return Icon(
      icon,
      color: isSelected ? AppColors.textDark : AppColors.textLight,
      size: 28,
    );
  }
}
