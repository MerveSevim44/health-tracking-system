import 'package:flutter/material.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:health_care/widgets/mood_blob.dart';
import 'package:health_care/widgets/pastel_components.dart';

// 📁 lib/screens/mood_selection_screen.dart

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  int selectedMoodIndex = -1;
  final List<String> moodLabels = ['Great', 'Good', 'Neutral', 'Bad', 'Awful'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        colors: const [
          AppColors.gradientYellowStart,
          AppColors.gradientYellowEnd,
        ],
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
                      icon: const Icon(Icons.arrow_back_ios),
                      color: AppColors.textDark,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.check),
                      color: AppColors.textDark,
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
                    child: const MoodBlob(
                      size: 200,
                      color: AppColors.moodHappy,
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
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(30),
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
                        setState(() {
                          selectedMoodIndex = index;
                        });
                      },
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
  }
}

// Wave painter for mood intensity visualization
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
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
