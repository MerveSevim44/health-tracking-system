import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/models/mood_model.dart';
import 'package:health_care/models/water_model.dart';
import 'package:health_care/screens/breathing_exercise_screen.dart';
import 'package:health_care/screens/chat.dart';
import 'package:health_care/theme/water_theme.dart';

// Geçici ChatScreen tanımı kaldırıldı, artık chat.dart kullanılıyor.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Alt bar için mevcut sayfa indeksi
  int _currentIndex = 2; // Sohbet sekmesi varsayılan olarak seçili

  // Alt bar sayfaları
  final List<Widget> _pages = [
    // 0. İndeks: Nefes Egzersizi Sayfası
    const BreathingExerciseScreen(),
    const Center(child: Text('İstatistikler Sayfası')),
    const MainContent(),
    const Center(child: Text('Ayarlar Sayfası')),
  ];

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
      // Body, seçili olan sayfayı gösterir
      body: _pages[_currentIndex],
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

          // 5. Eklenen Resim Widget'ı
          _buildNatureImage(context, lightCardColor, greyText),

          const SizedBox(height: 40), // Boşluk ayarlandı.

          // 6. Konuşmaya Hazır mısın? Kartı
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChatScreen()),
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