// 📁 lib/screens/mood_checkin_screen.dart
// Daily mood check-in screen - shown once per day on login

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care/services/mood_service.dart';
import 'package:health_care/services/chat_service.dart';
import 'package:health_care/services/ai_coach_service.dart';
import 'package:health_care/theme/app_theme.dart';
import 'package:health_care/theme/modern_colors.dart';

class MoodCheckinScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const MoodCheckinScreen({super.key, this.onComplete, this.onSkip});

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
  late Animation<double> _fadeAnimation;

  // Comprehensive emotions grouped by category
  final Map<String, List<Map<String, String>>> _emotionCategories = {
    'Positive': [
      {'key': 'happy', 'emoji': '😊', 'label': 'Happy'},
      {'key': 'calm', 'emoji': '😌', 'label': 'Calm'},
      {'key': 'energetic', 'emoji': '⚡', 'label': 'Energetic'},
      {'key': 'excited', 'emoji': '🤩', 'label': 'Excited'},
      {'key': 'grateful', 'emoji': '🙏', 'label': 'Grateful'},
      {'key': 'confident', 'emoji': '💪', 'label': 'Confident'},
    ],
    'Neutral / Low Energy': [
      {'key': 'tired', 'emoji': '😴', 'label': 'Tired'},
      {'key': 'indifferent', 'emoji': '😐', 'label': 'Indifferent'},
      {'key': 'thoughtful', 'emoji': '🤔', 'label': 'Thoughtful'},
    ],
    'Negative': [
      {'key': 'sad', 'emoji': '😢', 'label': 'Sad'},
      {'key': 'anxious', 'emoji': '😟', 'label': 'Anxious'},
      {'key': 'angry', 'emoji': '😠', 'label': 'Angry'},
      {'key': 'lonely', 'emoji': '😞', 'label': 'Lonely'},
      {'key': 'stressed', 'emoji': '😣', 'label': 'Stressed'},
      {'key': 'overwhelmed', 'emoji': '😔', 'label': 'Overwhelmed'},
    ],
  };

  // Mood levels with theme-aware colors
  final List<Map<String, dynamic>> _moodLevels = [
    {'level': 5, 'label': 'Great', 'emoji': '😄', 'color': AppColors.moodGreat},
    {'level': 4, 'label': 'Good', 'emoji': '🙂', 'color': AppColors.moodGood},
    {
      'level': 3,
      'label': 'Okay',
      'emoji': '😐',
      'color': AppColors.moodNeutral,
    },
    {
      'level': 2,
      'label': 'Not Good',
      'emoji': '😟',
      'color': AppColors.moodBad,
    },
    {'level': 1, 'label': 'Awful', 'emoji': '😢', 'color': AppColors.moodAwful},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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

      // 4. Generate AI response to mood (with Gemini)
      // Service handles all errors and returns fallback message - never throws
      final moodResponse = await aiCoachService.generateMoodResponse(
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

      setState(() => _isSaving = false);

      // 5. AI yanıtını dialog ile göster
      if (mounted) {
        await _showAiResponseDialog(moodResponse);
      }
    } catch (e) {
      // 🛡️ Silent error logging - this should rarely happen (only Firebase errors)
      // AI errors are handled by service and return fallback message
      debugPrint('❌ [Mood Check-in] Error saving mood (silent): ${e.runtimeType}');
      
      // Even if Firebase fails, show a fallback message to user
      if (mounted) {
        setState(() => _isSaving = false);
        
        // Show fallback message in dialog
        await _showAiResponseDialog(
          'Bugün kendine küçük bir iyilik yapmayı unutma 🌿'
        );
      }
    }
  }

  Future<void> _showAiResponseDialog(String aiResponse) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: ModernAppColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AI Coach Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: ModernAppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Title
                const Text(
                  'AI Health Coach',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ModernAppColors.lightText,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // AI Response
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: ModernAppColors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    aiResponse,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: ModernAppColors.lightText,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ModernAppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close dialog
                        if (widget.onComplete != null) {
                          widget.onComplete!();
                        } else {
                          Navigator.of(context).pop(true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: const Text(
                        'Continue to Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _skip() {
    debugPrint('ℹ️ Mood check-in skipped');
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      Navigator.of(context).pop(false);
    }
  }

  Color _getEmotionColor(String category) {
    switch (category) {
      case 'Positive':
        return AppColors.success;
      case 'Neutral / Low Energy':
        return AppColors.info;
      case 'Negative':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: _isSaving
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: ModernAppColors.vibrantCyan,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'Saving your mood...',
                        style: TextStyle(
                          color: ModernAppColors.lightText,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button - top left
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: _skip,
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: ModernAppColors.lightText,
                          ),
                          tooltip: 'Go back',
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Animated emoji
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ModernAppColors.deepPurple.withOpacity(0.3),
                                ModernAppColors.vibrantCyan.withOpacity(0.3),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('💙', style: TextStyle(fontSize: 48)),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Title
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          'How are you today?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: ModernAppColors.lightText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Subtitle
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Take a moment to check in with yourself ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ModernAppColors.mutedText,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text('💙', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Mood Level Selection
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ModernAppColors.cardBg,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                const Text(
                                  'How is your day going?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: ModernAppColors.lightText,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: _moodLevels.map((mood) {
                                    final isSelected =
                                        _selectedMoodLevel == mood['level'];
                                    final moodColor = mood['color'] as Color;

                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedMoodLevel =
                                                  mood['level'];
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeOutCubic,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: AppSpacing.md,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? moodColor.withOpacity(0.2)
                                                  : ModernAppColors.darkBg,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.lg,
                                                  ),
                                              border: Border.all(
                                                color: isSelected
                                                    ? moodColor
                                                    : ModernAppColors.mutedText
                                                          .withOpacity(0.3),
                                                width: isSelected ? 2.5 : 1,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: moodColor
                                                            .withOpacity(0.3),
                                                        blurRadius: 12,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  mood['emoji'],
                                                  style: TextStyle(
                                                    fontSize: isSelected
                                                        ? 40
                                                        : 36,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: AppSpacing.xs,
                                                ),
                                                Text(
                                                  mood['label'],
                                                  style: TextStyle(
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                    fontSize: 11,
                                                    color: ModernAppColors.lightText,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Emotions Selection - Grouped by Category
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ModernAppColors.cardBg,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                const Text(
                                  'What emotions are you feeling?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: ModernAppColors.lightText,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Select all that apply',
                                  style: TextStyle(
                                    color: ModernAppColors.mutedText,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Build emotion categories
                                ..._emotionCategories.entries.map((category) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Category Label
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: AppSpacing.sm,
                                          bottom: AppSpacing.sm,
                                        ),
                                        child: Text(
                                          category.key,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: ModernAppColors.mutedText,
                                            fontSize: 12,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),

                                      // Emotion chips for this category
                                      Wrap(
                                        spacing: AppSpacing.sm,
                                        runSpacing: AppSpacing.sm,
                                        alignment: WrapAlignment.start,
                                        children: category.value.map((emotion) {
                                          final isSelected = _selectedEmotions
                                              .contains(emotion['key']);
                                          Color emotionColor = _getEmotionColor(
                                            category.key,
                                          );

                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (isSelected) {
                                                  _selectedEmotions.remove(
                                                    emotion['key'],
                                                  );
                                                } else {
                                                  _selectedEmotions.add(
                                                    emotion['key']!,
                                                  );
                                                }
                                              });
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeOut,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: AppSpacing.md,
                                                    vertical: AppSpacing.sm,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? emotionColor.withOpacity(
                                                        0.2,
                                                      )
                                                    : ModernAppColors.darkBg,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.xl,
                                                    ),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? emotionColor
                                                      : ModernAppColors.mutedText
                                                            .withOpacity(0.3),
                                                  width: isSelected ? 2 : 1,
                                                ),
                                                boxShadow: isSelected
                                                    ? [
                                                        BoxShadow(
                                                          color: emotionColor
                                                              .withOpacity(0.2),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    emotion['emoji']!,
                                                    style: TextStyle(
                                                      fontSize: isSelected
                                                          ? 22
                                                          : 20,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: AppSpacing.xs,
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      emotion['label']!,
                                                      style: TextStyle(
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.w400,
                                                        fontSize: 14,
                                                        color: ModernAppColors.lightText,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),

                                      // Add spacing between categories
                                      if (category.key !=
                                          _emotionCategories.keys.last)
                                        const SizedBox(height: AppSpacing.lg),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Complete Button
                      AnimatedOpacity(
                        opacity:
                            (_selectedMoodLevel != null ||
                                _selectedEmotions.isNotEmpty)
                            ? 1.0
                            : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            gradient:
                                (_selectedMoodLevel != null ||
                                    _selectedEmotions.isNotEmpty)
                                ? ModernAppColors.primaryGradient
                                : null,
                            color:
                                (_selectedMoodLevel == null &&
                                    _selectedEmotions.isEmpty)
                                ? ModernAppColors.mutedText.withOpacity(0.3)
                                : null,
                          ),
                          child: ElevatedButton.icon(
                            onPressed:
                                (_selectedMoodLevel != null ||
                                    _selectedEmotions.isNotEmpty)
                                ? _saveMood
                                : null,
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 22,
                            ),
                            label: const Text(
                              'Complete Check-in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Skip for today text button
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Skip for today',
                          style: TextStyle(
                            color: ModernAppColors.mutedText,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// String extension for capitalizing first letter
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
