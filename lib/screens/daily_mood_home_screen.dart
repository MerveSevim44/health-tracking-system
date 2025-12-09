import 'package:flutter/material.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:health_care/widgets/pastel_components.dart';
import 'package:health_care/widgets/mood_blob.dart';
import 'package:fl_chart/fl_chart.dart';

// 📁 lib/screens/daily_mood_home_screen.dart

class DailyMoodHomeScreen extends StatelessWidget {
  const DailyMoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              const SizedBox(height: 32),

              // Greeting
              const Text(
                'Hello Ridgy! 👋',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'What\'s on your mind?',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(),

              const SizedBox(height: 32),

              // Daily Mood Log
              const Text(
                'Daily Mood Log',
                style: AppTextStyles.headlineMedium,
              ),

              const SizedBox(height: 16),

              _buildDailyMoodLog(),

              const SizedBox(height: 32),

              // Today's Task
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today\'s Task',
                    style: AppTextStyles.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.moodCalm,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Your Mood\nScore',
                      value: '7.5',
                      backgroundColor: AppColors.pastelYellow,
                      icon: const MoodBlob(
                        size: 40,
                        color: AppColors.moodHappy,
                        expression: MoodExpression.happy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Your Streak\nInformation',
                      value: '12 Days',
                      backgroundColor: AppColors.pastelPeach,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.moodHappy,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sleep Summary (from Analytics screen reference)
              _buildSleepSummary(),

              const SizedBox(height: 24),

              // My Mood breakdown
              _buildMyMood(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.pastelMint,
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: NetworkImage('https://via.placeholder.com/48'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person_add_outlined),
              color: AppColors.textDark,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.textDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildQuickActionChip('😊', 'Mood', AppColors.pastelYellow),
        const SizedBox(width: 8),
        _buildQuickActionChip('🧘', 'Meditation', AppColors.pastelLavender),
        const SizedBox(width: 8),
        _buildQuickActionChip('🎵', 'Music', AppColors.pastelPink),
      ],
    );
  }

  Widget _buildQuickActionChip(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMoodLog() {
    final moodData = [
      {'day': 'Sat', 'color': AppColors.moodHappy},
      {'day': 'Sun', 'color': AppColors.moodNeutral},
      {'day': 'Mon', 'color': AppColors.moodCalm},
      {'day': 'Tue', 'color': AppColors.moodSad},
      {'day': 'Wed', 'color': AppColors.moodHappy},
    ];

    return PastelCard(
      backgroundColor: AppColors.pastelMint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'This Week',
                style: AppTextStyles.bodyLarge,
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Skip Now',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.moodAnxious,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: moodData.map((data) {
              return MoodTile(
                day: data['day'] as String,
                color: data['color'] as Color,
                isToday: data['day'] == 'Wed',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepSummary() {
    return PastelCard(
      backgroundColor: AppColors.pastelPink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sleep Summary',
                style: AppTextStyles.headlineMedium,
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Edit',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.moodAnxious,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const times = ['11:00', '12:00', '01:00', '02:00', '03:00'];
                        if (value.toInt() < times.length) {
                          return Text(
                            times[value.toInt()],
                            style: AppTextStyles.bodySmall,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(5, (index) {
                  final colors = [
                    AppColors.pastelPink,
                    AppColors.moodCalm,
                    AppColors.moodHappy,
                    AppColors.pastelBlue,
                    AppColors.pastelMint,
                  ];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (index + 1) * 2.0,
                        color: colors[index],
                        width: 12,
                        borderRadius: BorderRadius.circular(6),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(AppColors.pastelPink, 'Core'),
              _buildLegendItem(AppColors.moodHappy, 'REM'),
              _buildLegendItem(AppColors.pastelMint, 'Post-REM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyMood() {
    final moods = [
      {'label': 'Sad pensive', 'percentage': '61%'},
      {'label': 'Grateful', 'percentage': '15%'},
      {'label': 'Angry', 'percentage': '24%'},
    ];

    return PastelCard(
      backgroundColor: AppColors.pastelLavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Mood',
                style: AppTextStyles.headlineMedium,
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.moodCalm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...moods.map((mood) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.emoji_emotions, size: 24, color: AppColors.moodHappy),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mood['label']!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                Text(
                  mood['percentage']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
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
}
