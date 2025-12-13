// 📁 lib/screens/mood_checkin_screen.dart
// Daily mood check-in screen - shown once per day on login

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care/services/mood_service.dart';
import 'package:health_care/services/chat_service.dart';
import 'package:health_care/services/ai_coach_service.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:health_care/screens/chat_screen.dart';

class MoodCheckinScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const MoodCheckinScreen({
    super.key,
    this.onComplete,
    this.onSkip,
  });

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedMoodLevel;
  final Set<String> _selectedEmotions = {};
  bool _isSaving = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Emotions with emojis
  final Map<String, String> _emotions = {
    'happy': '😊',
    'sad': '😢',
    'angry': '😠',
    'calm': '😌',
    'anxious': '😰',
    'tired': '😴',
    'energetic': '⚡',
    'excited': '🎉',
  };

  // Mood levels
  final List<Map<String, dynamic>> _moodLevels = [
    {'level': 5, 'label': 'Great', 'emoji': '😄', 'color': Color(0xFFFFD93D)},
    {'level': 4, 'label': 'Good', 'emoji': '🙂', 'color': Color(0xFFB4E197)},
    {'level': 3, 'label': 'Neutral', 'emoji': '😐', 'color': Color(0xFFD4A5A5)},
    {'level': 2, 'label': 'Bad', 'emoji': '😟', 'color': Color(0xFFCBA6C3)},
    {'level': 1, 'label': 'Awful', 'emoji': '😢', 'color': Color(0xFFB5C6E0)},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    if (_selectedMoodLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood level'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final moodService = MoodService();
      final chatService = ChatService();
      final aiCoachService = AiCoachService();

      // 1. Save mood to Firebase
      await moodService.addMood(
        moodLevel: _selectedMoodLevel!,
        emotions: _selectedEmotions.toList(),
        notes: '',
        sentimentScore: 0.0,
        sentimentMagnitude: 0.0,
      );
      debugPrint('✅ Mood saved successfully');

      // 2. Get or create today's check-in session
      final sessionId = await chatService.getTodayCheckInSession(userId);
      debugPrint('📝 Chat session: $sessionId');

      // 3. Add AI welcome message
      final welcomeMessage = aiCoachService.generateCheckInWelcome();
      await chatService.addMessage(
        userId: userId,
        sessionId: sessionId,
        sender: 'ai',
        text: welcomeMessage,
        sentiment: 'positive',
      );

      // 4. Add AI response to mood (using static advice)
      final moodResponse = aiCoachService.generateMoodResponse(
        moodLevel: _selectedMoodLevel!,
        emotions: _selectedEmotions.toList(),
      );
      await chatService.addMessage(
        userId: userId,
        sessionId: sessionId,
        sender: 'ai',
        text: moodResponse,
        sentiment: _selectedMoodLevel! >= 3 ? 'positive' : 'neutral',
      );
      debugPrint('🤖 AI messages added to chat');

      if (mounted) {
        // First, complete the mood check-in (goes to home)
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
        
        // Then navigate to chat screen to show the advice
        // Use a small delay to ensure home navigation is complete
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(sessionId: sessionId),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving mood: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  void _skip() {
    debugPrint('ℹ️ Mood check-in skipped');
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: _isSaving
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.moodHappy),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Skip button
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: _skip,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: const Text(
                          'How are you today?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            height: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      FadeTransition(
                        opacity: _scaleAnimation,
                        child: const Text(
                          'Take a moment to check in with yourself',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Mood Level Selection
                      FadeTransition(
                        opacity: _scaleAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'How would you rate your day?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: _moodLevels.map((mood) {
                                  final isSelected =
                                      _selectedMoodLevel == mood['level'];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedMoodLevel = mood['level'];
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? mood['color'].withOpacity(0.3)
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? mood['color']
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            mood['emoji'],
                                            style: const TextStyle(
                                              fontSize: 32,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            mood['label'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Emotions Selection
                      FadeTransition(
                        opacity: _scaleAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'What emotions are you feeling?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'You can select multiple',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: _emotions.entries.map((entry) {
                                  final isSelected = _selectedEmotions.contains(
                                    entry.key,
                                  );
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedEmotions.remove(entry.key);
                                        } else {
                                          _selectedEmotions.add(entry.key);
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.moodHappy.withOpacity(
                                                0.2,
                                              )
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.moodHappy
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            entry.value,
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            entry.key,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedMoodLevel != null
                              ? _saveMood
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.moodHappy,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: _selectedMoodLevel != null ? 4 : 0,
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
