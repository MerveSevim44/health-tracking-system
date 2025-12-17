import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:health_care/theme/modern_colors.dart';
import 'package:health_care/widgets/mood_blob.dart';
import 'package:health_care/widgets/pastel_components.dart';
import 'package:health_care/widgets/mood/emotion_chips.dart';
import 'package:health_care/models/mood_model.dart';

// 📁 lib/screens/mood_selection_screen.dart

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  final List<String> moodLabels = ['Great', 'Good', 'Neutral', 'Bad', 'Awful'];
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    final moodModel = Provider.of<MoodModel>(context, listen: false);
    
    try {
      await moodModel.saveMood();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, child) {
        final selectedMoodIndex = moodModel.selectedMoodIndex;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernAppColors.darkBg,
              ModernAppColors.cardBg,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: ModernAppColors.lightText,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: selectedMoodIndex >= 0 ? _saveMood : null,
                      icon: const Icon(Icons.check),
                      color: selectedMoodIndex >= 0 
                          ? ModernAppColors.vibrantCyan
                          : ModernAppColors.mutedText,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'How are you really\nfeeling today?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ModernAppColors.lightText,
                  ),
                ),
              ),

              const Spacer(),

              // Animated Blob
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0.8, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: MoodBlob(
                      size: 200,
                      color: ModernAppColors.vibrantCyan,
                      expression: MoodExpression.happy,
                      animated: true,
                    ),
                  );
                },
              ),

              const Spacer(),

              // Mood intensity bar (visual representation)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: ModernAppColors.cardBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: ModernAppColors.mutedText.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated wave indicator
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 20,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: CustomPaint(
                            painter: WavePainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Mood options at bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    moodLabels.length,
                    (index) => MoodOptionButton(
                      label: moodLabels[index],
                      isSelected: selectedMoodIndex == index,
                      onTap: () {
                        moodModel.selectMood(index);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ⭐ Emotion chips for multi-select
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling?',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: ModernAppColors.lightText,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EmotionChips(
                      selectedEmotions: moodModel.selectedEmotions,
                      onEmotionToggle: (emotion) => moodModel.toggleEmotion(emotion),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ⭐ Notes field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _notesController,
                  onChanged: (value) => moodModel.updateDailyNote(value),
                  maxLines: 3,
                  style: const TextStyle(
                    color: ModernAppColors.lightText,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add notes about your day...',
                    hintStyle: TextStyle(
                      color: ModernAppColors.mutedText.withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: ModernAppColors.cardBg.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: ModernAppColors.mutedText.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: ModernAppColors.mutedText.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: ModernAppColors.vibrantCyan,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
        },
      );
  }
}

// Wave painter for mood intensity visualization
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ModernAppColors.vibrantCyan.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final waveHeight = size.height / 4;
    final waveLength = size.width / 5;

    path.moveTo(0, size.height / 2);

    for (double i = 0; i < size.width; i++) {
      path.lineTo(
        i,
        size.height / 2 + waveHeight * (i / waveLength).sin(),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => false;
}

// Extension for sin function
extension on double {
  double sin() => 0; // Simplified for demo
}
