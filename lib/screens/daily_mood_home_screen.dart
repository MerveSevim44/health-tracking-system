import 'package:flutter/material.dart';
import 'package:health_care/theme/modern_colors.dart';
import 'package:health_care/screens/mood_checkin_screen.dart';
import 'package:health_care/services/water_service.dart';
import 'package:health_care/services/medication_service.dart';
import 'package:health_care/services/sleep_service.dart';
import 'package:health_care/services/mood_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:ui';


class DailyMoodHomeScreen extends StatefulWidget {
  final String? username;

  const DailyMoodHomeScreen({super.key, this.username});

  @override
  State<DailyMoodHomeScreen> createState() => _DailyMoodHomeScreenState();
}

class _DailyMoodHomeScreenState extends State<DailyMoodHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  final WaterService _waterService = WaterService();
  final MedicationService _medicationService = MedicationService();
  final SleepService _sleepService = SleepService();
  final MoodService _moodService = MoodService();
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  // Real data
  int _waterTodayML = 0;
  int _waterGoalML = 2000;
  int _medicationTaken = 0;
  int _medicationTotal = 0;
  String _sleepDuration = 'No data';
  Map<String, double> _emotionDistribution = {};
  
  // Mood score data
  double _moodScore = 0.0;
  String _moodLabel = '';
  bool _hasMoodData = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    await Future.wait([
      _loadWaterData(),
      _loadMedicationData(),
      _loadSleepData(),
      _loadEmotionDistribution(),
      _loadMoodScore(),
    ]);
  }

  Future<void> _loadWaterData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Get today's water intake
      final today = DateTime.now();
      final todayTotal = await _waterService.getTotalIntakeForDate(today);
      
      // Get user's water goal
      final goalSnapshot = await _database.ref('users/$userId/waterGoalMl').get();
      final goalMl = goalSnapshot.value as int?;
      
      if (mounted) {
        setState(() {
          _waterTodayML = todayTotal;
          _waterGoalML = goalMl ?? 2000;
        });
        debugPrint("Water today: $_waterTodayML / $_waterGoalML ml");
      }
    } catch (e) {
      debugPrint('Error loading water data: $e');
    }
  }

  Future<void> _loadMedicationData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Get all active medications
      final medicationsSnapshot = await _database.ref('medications/$userId').get();
      final medicationsData = medicationsSnapshot.value as Map<dynamic, dynamic>?;
      
      if (medicationsData == null) {
        if (mounted) {
          setState(() {
            _medicationTaken = 0;
            _medicationTotal = 0;
          });
        }
        return;
      }

      // Calculate total scheduled slots for today
      int totalSlots = 0;
      for (var medEntry in medicationsData.entries) {
        final medData = medEntry.value as Map;
        if (medData['active'] != true) continue;

        final frequency = medData['frequency'] as Map? ?? {};
        if (frequency['morning'] == true) totalSlots++;
        if (frequency['afternoon'] == true) totalSlots++;
        if (frequency['evening'] == true) totalSlots++;
      }

      // Get taken count for today
      final takenCount = await _medicationService.getTodayCompletionCount();

      if (mounted) {
        setState(() {
          _medicationTotal = totalSlots;
          _medicationTaken = takenCount;
        });
        debugPrint("Medication taken today: $_medicationTaken / $_medicationTotal");
      }
    } catch (e) {
      debugPrint('Error loading medication data: $e');
    }
  }

  // Data source: Firebase → sleep_logs/{uid}/{YYYY-MM-DD}
  Future<void> _loadSleepData() async {
    try {
      // Check today's sleep first, then yesterday's (most recent)
      final recentSleep = await _sleepService.getRecentSleep();
      
      if (recentSleep != null) {
        if (mounted) {
          setState(() {
            _sleepDuration = recentSleep.formattedDuration;
          });
          debugPrint("Sleep last night: $_sleepDuration");
        }
      } else {
        // No sleep data for today or yesterday
        if (mounted) {
          setState(() {
            _sleepDuration = 'No sleep data logged';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading sleep data: $e');
      if (mounted) {
        setState(() {
          _sleepDuration = 'No sleep data logged';
        });
      }
    }
  }

  // Data source: Firebase → moods/{uid}/{YYYY-MM-DD}/emotions[]
  Future<void> _loadEmotionDistribution() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Get last 7 days of moods
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      
      final emotionFrequency = await _moodService.getEmotionFrequency(weekAgo, now);
      
      if (emotionFrequency.isEmpty) {
        if (mounted) {
          setState(() {
            _emotionDistribution = {};
          });
        }
        return;
      }

      // Calculate total emotions
      final totalEmotions = emotionFrequency.values.fold<int>(0, (sum, count) => sum + count);
      
      // If no emotions found, return empty
      if (totalEmotions == 0) {
        if (mounted) {
          setState(() {
            _emotionDistribution = {};
          });
        }
        return;
      }

      // Calculate percentages: (emotion_count / total_emotion_count) * 100
      final Map<String, double> distribution = {};
      emotionFrequency.forEach((emotion, count) {
        distribution[emotion] = (count / totalEmotions) * 100;
      });

      if (mounted) {
        setState(() {
          _emotionDistribution = distribution;
        });
        debugPrint("Emotion distribution: $_emotionDistribution");
      }
    } catch (e) {
      debugPrint('Error loading emotion distribution: $e');
    }
  }

  /// Load mood score - uses today's mood if available, otherwise last 7 days average
  Future<void> _loadMoodScore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // First, try to get today's mood
      final todayMood = await _moodService.getTodayMood();
      
      if (todayMood != null) {
        // Convert 1-5 scale to 10-point scale (1→2, 5→10)
        final score = todayMood.moodLevel * 2.0;
        
        if (mounted) {
          setState(() {
            _moodScore = score;
            _moodLabel = _getMoodMessage(todayMood.moodLevel);
            _hasMoodData = true;
          });
          debugPrint("Today's mood score: $_moodScore (level: ${todayMood.moodLevel})");
        }
        return;
      }

      // If no today's mood, get weekly average
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final averageMood = await _moodService.getAverageMoodLevel(weekAgo, now);
      
      if (averageMood > 0) {
        // Convert 1-5 scale to 10-point scale
        final score = averageMood * 2.0;
        
        if (mounted) {
          setState(() {
            _moodScore = score;
            _moodLabel = _getMoodMessage(averageMood.round());
            _hasMoodData = true;
          });
          debugPrint("Weekly average mood score: $_moodScore");
        }
      } else {
        // No mood data at all
        if (mounted) {
          setState(() {
            _moodScore = 0.0;
            _moodLabel = '';
            _hasMoodData = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading mood score: $e');
      if (mounted) {
        setState(() {
          _hasMoodData = false;
        });
      }
    }
  }

  /// Get friendly message based on mood level
  String _getMoodMessage(int moodLevel) {
    switch (moodLevel) {
      case 5:
        return 'Amazing day! 🎉';
      case 4:
        return 'Great today! 🌟';
      case 3:
        return 'Doing okay 👍';
      case 2:
        return 'Hang in there 💪';
      case 1:
        return 'Take it easy 💙';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayUsername = widget.username ?? 'Friend';

    return Stack(
      children: [
        // Animated background
        _buildAnimatedBackground(),
        
        // Main content
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 20, 20, kBottomNavigationBarHeight + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  
                  // Today's Stats - 3 Cards
                  _buildTrackingCards(),
                  
                  const SizedBox(height: 30),
                  
                  // Emotion Distribution
                  _buildEmotionDistribution(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
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
        if (label == 'Log Mood') {
          debugPrint("Mood route opened");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MoodCheckinScreen(),
            ),
          );
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
    return GestureDetector(
      onTap: () async {
        // Navigate to mood check-in and refresh data when returning
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MoodCheckinScreen(),
          ),
        );
        // Refresh mood score after returning
        _loadMoodScore();
      },
      child: Container(
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
              child: Icon(
                _hasMoodData ? Icons.emoji_emotions_rounded : Icons.add_reaction_outlined,
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
                  Text(
                    _hasMoodData ? _moodScore.toStringAsFixed(1) : '--',
                    style: const TextStyle(
                      color: ModernAppColors.lightText,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _hasMoodData ? _moodLabel : 'Tap to log your mood',
                    style: TextStyle(
                      color: ModernAppColors.lightText.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow indicator
            Icon(
              Icons.chevron_right_rounded,
              color: ModernAppColors.lightText.withOpacity(0.7),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildWaterCard(),
        const SizedBox(height: 12),
        _buildMedicationCard(),
        const SizedBox(height: 12),
        _buildSleepCard(),
      ],
    );
  }

  Widget _buildWaterCard() {
    final progress = _waterGoalML > 0 ? (_waterTodayML / _waterGoalML).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/water/home');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ModernAppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ModernAppColors.vibrantCyan.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Left: Circular icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ModernAppColors.vibrantCyan.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.water_drop_rounded,
                    color: ModernAppColors.vibrantCyan,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Center: Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Water Intake',
                        style: TextStyle(
                          color: ModernAppColors.lightText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_waterTodayML / $_waterGoalML ml',
                        style: const TextStyle(
                          color: ModernAppColors.mutedText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: Percentage
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: ModernAppColors.vibrantCyan,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bottom: Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: ModernAppColors.vibrantCyan.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(ModernAppColors.vibrantCyan),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard() {
    final hasPending = _medicationTotal > 0 && _medicationTaken < _medicationTotal;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/medication');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ModernAppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ModernAppColors.accentOrange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Left: Medication icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ModernAppColors.accentOrange.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: ModernAppColors.accentOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Center: Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medication',
                        style: TextStyle(
                          color: ModernAppColors.lightText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_medicationTaken / $_medicationTotal taken',
                        style: const TextStyle(
                          color: ModernAppColors.mutedText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasPending) ...[
              const SizedBox(height: 12),
              Text(
                'You have pending medication',
                style: TextStyle(
                  color: ModernAppColors.accentOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSleepCard() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/sleep-tracking');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ModernAppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ModernAppColors.deepPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Left: Moon icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ModernAppColors.deepPurple.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bedtime_rounded,
                    color: ModernAppColors.deepPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Center: Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sleep',
                        style: TextStyle(
                          color: ModernAppColors.lightText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _sleepDuration == 'No sleep data logged' 
                          ? 'No data' 
                          : _sleepDuration,
                        style: TextStyle(
                          color: _sleepDuration == 'No sleep data logged'
                            ? ModernAppColors.mutedText.withOpacity(0.7)
                            : ModernAppColors.mutedText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _sleepDuration == 'No sleep data logged'
                ? 'Tap to log your sleep'
                : "Last night's sleep",
              style: TextStyle(
                color: ModernAppColors.mutedText.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emotion Distribution',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 16),
        
        // Show message if no data
        if (_emotionDistribution.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ModernAppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ModernAppColors.mutedText.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: ModernAppColors.mutedText.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No mood data yet',
                    style: TextStyle(
                      color: ModernAppColors.mutedText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your moods to see patterns',
                    style: TextStyle(
                      color: ModernAppColors.mutedText.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Sort by percentage (descending) and take top emotions
          ...() {
            final sortedEmotions = _emotionDistribution.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            
            return sortedEmotions.take(5).map((entry) {
              final emotion = entry.key;
              final percentage = entry.value;
              
              // Get emotion color (use predefined colors or default)
              Color emotionColor = _getEmotionColor(emotion);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Color dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: emotionColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Label
                    Expanded(
                      child: Text(
                        _capitalizeEmotion(emotion),
                        style: const TextStyle(
                          color: ModernAppColors.lightText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Percentage with decimal
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: ModernAppColors.mutedText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          }(),
        ],
      ],
    );
  }

  Color _getEmotionColor(String emotion) {
    final emotionLower = emotion.toLowerCase();
    switch (emotionLower) {
      case 'happy':
      case 'excited':
      case 'grateful':
        return ModernAppColors.accentGreen;
      case 'sad':
      case 'lonely':
        return ModernAppColors.accentPink;
      case 'anxious':
      case 'stressed':
      case 'overwhelmed':
        return ModernAppColors.accentOrange;
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return ModernAppColors.vibrantCyan;
      case 'angry':
      case 'frustrated':
        return Colors.red;
      case 'tired':
        return ModernAppColors.deepPurple;
      default:
        return ModernAppColors.mutedText;
    }
  }

  String _capitalizeEmotion(String emotion) {
    if (emotion.isEmpty) return emotion;
    return emotion[0].toUpperCase() + emotion.substring(1);
  }
}
