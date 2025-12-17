import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/mood_model.dart';
import 'package:health_care/models/water_model.dart';
import 'package:health_care/models/sleep_model.dart';
import 'package:health_care/screens/chat.dart';
import 'package:health_care/screens/sleep_tracking_screen.dart';
import 'package:health_care/screens/sleep_details_screen.dart';
import 'package:health_care/services/sleep_service.dart';
import 'package:health_care/services/mood_service.dart';
import 'package:health_care/theme/water_theme.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:health_care/utils/page_transitions.dart';
import 'package:health_care/models/mood_firebase_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Destekli Sağlık Takip Sistemi',
          style: TextStyle(fontSize: 22),
        ),
        automaticallyImplyLeading: false,
      ),
      body: const MainContent(),
    );
  }
}

// --- Ana Sayfa İçeriği Widget'ı ---
class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema renklerini kullanmak için varsayılan değerler
    final Color greyText = const Color(0xFF757575);
    final Color lightCardColor = const Color(0xFFF5F5F5);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Üst Kısım: Karşılama ve Takvim
          _buildHeader(context, greyText),

          const SizedBox(height: 30),

          // 2. Ruh Hali Seçimi Başlığı
          const Text(
            'Bugün nasıl hissediyorsun?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // 3. Ruh Hali İkonları
          const MoodSelector(),

          const SizedBox(height: 40),

          // 4. Su Takibi Kartı
          const WaterTrackingCard(),

          const SizedBox(height: 24),

          // 4.5 Sleep Tracking Card
          const SleepTrackingCard(),

          const SizedBox(height: 24),

          // 4.6 Emotion Distribution Card
          const EmotionDistributionCard(),

          const SizedBox(height: 24),

          // 5. Nefes Egzersizi Kartı
          _buildBreathingCard(context, lightCardColor),

          const SizedBox(height: 24),

          // 6. Eklenen Resim Widget'ı
          _buildNatureImage(context, lightCardColor, greyText),

          const SizedBox(height: 40), // Boşluk ayarlandı.

          // 7. Konuşmaya Hazır mısın? Kartı
          const ConversationCard(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color greyText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'Merhaba, Duygu',
              style: TextStyle(color: greyText, fontSize: 16),
            ),
          ],
        ),
        Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color, size: 20),
      ],
    );
  }

  Widget _buildBreathingCard(BuildContext context, Color lightCardColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B8EFF), Color(0xFF8BA4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B8EFF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/breathing'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nefes Egzersizi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stres ve kaygıyı azaltmak için nefes al',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNatureImage(BuildContext context, Color lightCardColor, Color greyText) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: lightCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/nature.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 40, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    'nature.jpg yüklenemedi. Yol: assets/images/',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: greyText),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Ruh Hali Seçici Widget'ı (MoodSelector) ---
class MoodSelector extends StatelessWidget {
  const MoodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    // Renklerin theme.dart'tan geldiğini varsayıyoruz.
    const Color primaryGreen = Color(0xFF009000);

    final selectedIndex = context.watch<MoodModel>().selectedMoodIndex;

    const List<Map<String, dynamic>> moods = [
      {'label': 'Mutlu', 'icon': Icons.sentiment_very_satisfied, 'color': primaryGreen},
      {'label': 'Sakin', 'icon': Icons.sentiment_satisfied, 'color': Color(0xFF2196F3)},
      {'label': 'Üzgün', 'icon': Icons.sentiment_dissatisfied, 'color': Color(0xFFFF9800)},
      {'label': 'Kaygılı', 'icon': Icons.sentiment_neutral, 'color': Color(0xFFE91E63)},
      {'label': 'Kızgın', 'icon': Icons.sentiment_very_dissatisfied, 'color': Color(0xFFF44336)},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(moods.length, (index) {
        return _MoodIcon(
          mood: moods[index],
          isSelected: index == selectedIndex,
          onTap: () {
            Provider.of<MoodModel>(context, listen: false).selectMood(index);
          },
        );
      }),
    );
  }
}

// --- Ruh Hali İkonu Widget'ı (_MoodIcon) ---
class _MoodIcon extends StatelessWidget {
  final Map<String, dynamic> mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodIcon({required this.mood, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color greyText = const Color(0xFF757575);
    final opacity = isSelected ? 1.0 : 0.4;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (mood['color'] as Color).withOpacity(opacity),
              border: isSelected
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : null,
            ),
            child: Icon(
              mood['icon'] as IconData,
              size: 32,
              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            mood['label'] as String,
            style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : greyText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// --- ConversationCard (Sohbet Butonu) ---
class ConversationCard extends StatelessWidget {
  const ConversationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Color lightCardColor = const Color(0xFFF5F5F5);
    final Color greyText = const Color(0xFF757575);

    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        final isMoodSelected = moodModel.selectedMoodIndex != -1;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: lightCardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Konuşmaya hazır mısın?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yapay zeka asistanın seni dinlemek için burada.',
                      style: TextStyle(color: greyText),
                    ),
                    const SizedBox(height: 15),

                    // İstenen İkon Buton (Küçük, Yeşil, Yazısız)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isMoodSelected
                            ? Theme.of(context).primaryColor
                            : greyText.withOpacity(0.5),
                        shape: BoxShape.circle,
                        boxShadow: isMoodSelected ? [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ] : null,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        color: Colors.white,
                        iconSize: 24,
                        onPressed: isMoodSelected
                            ? () {
                          // Ruh hali seçilmişse ChatScreen'e yönlendir
                          // chat.dart dosyasından ChatScreen'i çağırır
                          Navigator.of(context).pushFadeSlide(
                            const ChatScreen(),
                          );
                        }
                            : () {
                          // Ruh hali seçilmemişse uyarı ver
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen önce bugün nasıl hissettiğini seç!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.water_damage_outlined, size: 40, color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Su Takip Kartı Widget'ı ---
class WaterTrackingCard extends StatelessWidget {
  const WaterTrackingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterModel>(
      builder: (context, waterModel, child) {
        final currentIntake = waterModel.getCurrentIntake();
        final dailyGoal = waterModel.dailyGoal;
        final progress = waterModel.getProgress();

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/water/home');
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE1F5FE),
                  Color(0xFFFFFFFF),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: WaterColors.waterPrimary.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: WaterColors.waterPrimary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.water_drop,
                            color: WaterColors.waterPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Su Takibi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: WaterColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: WaterColors.textLight,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Progress bar
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: WaterColors.waterLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: WaterColors.waterBlobGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currentIntake ml / $dailyGoal ml',
                      style: WaterTextStyles.bodyLarge.copyWith(
                        color: WaterColors.textDark,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: WaterTextStyles.headlineMedium.copyWith(
                        fontSize: 18,
                        color: WaterColors.waterDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Harika gidiyorsun! Su içmeye devam et 💧',
                  style: WaterTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Sleep Tracking Card Widget ---
class SleepTrackingCard extends StatefulWidget {
  const SleepTrackingCard({super.key});

  @override
  State<SleepTrackingCard> createState() => _SleepTrackingCardState();
}

class _SleepTrackingCardState extends State<SleepTrackingCard> {
  final SleepService _sleepService = SleepService();
  SleepLog? _recentSleep;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentSleep();
  }

  // Data source: Firebase → sleep_logs/{uid}/{YYYY-MM-DD}
  Future<void> _loadRecentSleep() async {
    try {
      final sleep = await _sleepService.getRecentSleep();
      if (mounted) {
        setState(() {
          _recentSleep = sleep;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading recent sleep: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SleepTrackingScreen()),
        );
        if (result == true) {
          _loadRecentSleep(); // Reload data after logging sleep
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF7B68EE).withOpacity(0.15),
              const Color(0xFF9D84FF).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF7B68EE).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B68EE).withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B68EE).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bedtime_rounded,
                        color: Color(0xFF7B68EE),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sleep Tracking',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_recentSleep != null)
                      IconButton(
                        icon: const Icon(Icons.bar_chart_rounded, size: 20),
                        color: const Color(0xFF7B68EE),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SleepDetailsScreen(),
                            ),
                          );
                        },
                      ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_recentSleep != null) ...[
              // Sleep data exists - show simple format
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    "Last night's sleep: ${_recentSleep!.formattedDuration}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7B68EE),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // No sleep data
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bedtime_outlined,
                        size: 48,
                        color: (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No sleep data logged',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to log your sleep',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}

// --- Emotion Distribution Card Widget ---
class EmotionDistributionCard extends StatefulWidget {
  const EmotionDistributionCard({super.key});

  @override
  State<EmotionDistributionCard> createState() => _EmotionDistributionCardState();
}

class _EmotionDistributionCardState extends State<EmotionDistributionCard> {
  final MoodService _moodService = MoodService();
  Map<String, double> _emotionDistribution = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmotionDistribution();
  }

  // Data source: Firebase → moods/{uid}/{YYYY-MM-DD}/emotions[]
  Future<void> _loadEmotionDistribution() async {
    try {
      final distribution = await _moodService.getLast7DaysEmotionDistribution();
      if (mounted) {
        setState(() {
          _emotionDistribution = distribution;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading emotion distribution: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B9D).withOpacity(0.12),
            const Color(0xFFFFA8C5).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B9D).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B9D).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: Color(0xFFFF6B9D),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Emotion Distribution',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_emotionDistribution.isEmpty) ...[
            // No mood data
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.mood_outlined,
                      size: 48,
                      color: (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No mood data yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your moods to see patterns',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Show emotion distribution
            Text(
              'Last 7 days',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ..._emotionDistribution.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEmotionBar(
                  emotion: entry.key,
                  percentage: entry.value,
                  isDark: isDark,
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionBar({
    required String emotion,
    required double percentage,
    required bool isDark,
  }) {
    // Get color for emotion
    final color = _getEmotionColor(emotion);
    final emoji = EmotionsList.getEmoji(emotion);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  emotion.capitalize(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkCardBg : const Color(0xFFF0F0F0)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getEmotionColor(String emotion) {
    // Map emotions to colors
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'excited':
      case 'grateful':
        return const Color(0xFF4CAF50);
      case 'calm':
      case 'relaxed':
      case 'peaceful':
        return const Color(0xFF2196F3);
      case 'sad':
      case 'tired':
        return const Color(0xFF9E9E9E);
      case 'anxious':
      case 'stressed':
      case 'overwhelmed':
        return const Color(0xFFFF9800);
      case 'angry':
      case 'frustrated':
        return const Color(0xFFF44336);
      case 'confident':
      case 'energetic':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF607D8B);
    }
  }
}

// String extension for capitalize
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}