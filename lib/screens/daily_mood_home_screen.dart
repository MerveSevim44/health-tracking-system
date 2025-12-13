import 'package:flutter/material.dart';
import 'package:health_care/theme/modern_colors.dart';
import 'dart:ui';


class DailyMoodHomeScreen extends StatefulWidget {
  final String? username;

  const DailyMoodHomeScreen({super.key, this.username});

  @override
  State<DailyMoodHomeScreen> createState() => _DailyMoodHomeScreenState();
}

class _DailyMoodHomeScreenState extends State<DailyMoodHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

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
    final displayUsername = widget.username ?? 'Friend';

    return Scaffold(
      backgroundColor: ModernAppColors.darkBg,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  
                  // Greeting Header
                  _buildGreetingHeader(displayUsername),
                  
                  const SizedBox(height: 30),
                  
                  // Quick Actions
                  _buildQuickActions(context),
                  
                  const SizedBox(height: 30),
                  
                  // Mood Score Card
                  _buildMoodScoreCard(),
                  
                  const SizedBox(height: 25),
                  
                  // Today's Stats
                  _buildTodayStats(),
                  
                  const SizedBox(height: 25),
                  
                  // Recent Activities
                  _buildRecentActivities(),
                  
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
              top: 100 + (_floatController.value * 50),
              right: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ModernAppColors.deepPurple.withOpacity(0.2),
                      ModernAppColors.deepPurple.withOpacity(0.0),
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

  Widget _buildGreetingHeader(String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $username! 👋',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'How are you feeling today?',
          style: TextStyle(
            fontSize: 16,
            color: ModernAppColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.mood_rounded,
        'label': 'Log Mood',
        'color': ModernAppColors.accentPink,
        'route': '/mood',
      },
      {
        'icon': Icons.water_drop_rounded,
        'label': 'Water',
        'color': ModernAppColors.vibrantCyan,
        'route': '/water/home',
      },
      {
        'icon': Icons.medication_rounded,
        'label': 'Meds',
        'color': ModernAppColors.accentOrange,
        'route': '/medication',
      },
      {
        'icon': Icons.self_improvement_rounded,
        'label': 'Breathe',
        'color': ModernAppColors.accentGreen,
        'route': '/breathing',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return _buildQuickActionButton(
              context,
              action['icon'] as IconData,
              action['label'] as String,
              action['color'] as Color,
              action['route'] as String,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    String route,
  ) {
    return GestureDetector(
      onTap: () {
        if (route == '/mood') {
          Navigator.pushNamed(context, '/mood');
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          color: ModernAppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: ModernAppColors.lightText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodScoreCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: ModernAppColors.primaryGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          ModernAppColors.primaryShadow(opacity: 0.4),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_emotions_rounded,
              color: ModernAppColors.lightText,
              size: 35,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Mood Score',
                  style: TextStyle(
                    color: ModernAppColors.lightText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '8.5',
                  style: TextStyle(
                    color: ModernAppColors.lightText,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Great today! 🎉',
                  style: TextStyle(
                    color: ModernAppColors.lightText.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Progress",
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
              child: _buildStatCard(
                'Water',
                '6/8',
                'glasses',
                Icons.water_drop_rounded,
                ModernAppColors.vibrantCyan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Meds',
                '2/3',
                'taken',
                Icons.medication_rounded,
                ModernAppColors.accentOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: ModernAppColors.mutedText,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: ModernAppColors.lightText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: ModernAppColors.mutedText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    final activities = [
      {'title': 'Morning meditation', 'time': '8:30 AM', 'icon': Icons.self_improvement},
      {'title': 'Mood check-in', 'time': '10:15 AM', 'icon': Icons.mood},
      {'title': 'Water logged', 'time': '11:30 AM', 'icon': Icons.water_drop},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 15),
        ...activities.map((activity) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ModernAppColors.cardBg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: ModernAppColors.deepPurple.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: ModernAppColors.deepPurple,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['title'] as String,
                        style: const TextStyle(
                          color: ModernAppColors.lightText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity['time'] as String,
                        style: const TextStyle(
                          color: ModernAppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
