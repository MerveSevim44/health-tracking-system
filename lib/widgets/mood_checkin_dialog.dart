// 📁 lib/widgets/mood_checkin_dialog.dart
// Compact modal dialog for daily mood check-in

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_care/services/mood_service.dart';
import 'package:health_care/services/chat_service.dart';
import 'package:health_care/services/ai_coach_service.dart';
import 'package:health_care/theme/modern_colors.dart';
import 'package:health_care/screens/chat_screen.dart';
import 'dart:ui';

class MoodCheckinDialog extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const MoodCheckinDialog({
    super.key,
    this.onComplete,
    this.onSkip,
  });

  @override
  State<MoodCheckinDialog> createState() => _MoodCheckinDialogState();
}

class _MoodCheckinDialogState extends State<MoodCheckinDialog>
    with SingleTickerProviderStateMixin {
  int? _selectedMoodLevel;
  final Set<String> _selectedEmotions = {};
  bool _isSaving = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Emotions with emojis (compact set)
  final Map<String, String> _emotions = {
    'happy': '😊',
    'sad': '😢',
    'calm': '😌',
    'anxious': '😰',
    'tired': '😴',
    'energetic': '⚡',
  };

  // Mood levels
  final List<Map<String, dynamic>> _moodLevels = [
    {'level': 5, 'label': 'Great', 'emoji': '😄', 'color': Color(0xFFFFD93D)},
    {'level': 4, 'label': 'Good', 'emoji': '🙂', 'color': Color(0xFFB4E197)},
    {'level': 3, 'label': 'OK', 'emoji': '😐', 'color': Color(0xFFD4A5A5)},
    {'level': 2, 'label': 'Bad', 'emoji': '😟', 'color': Color(0xFFCBA6C3)},
    {'level': 1, 'label': 'Awful', 'emoji': '😢', 'color': Color(0xFFB5C6E0)},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
          duration: Duration(seconds: 2),
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
        // Close dialog first
        Navigator.of(context).pop();
        
        // Call onComplete callback
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
        
        // Navigate to chat screen to show the advice
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
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  void _skip() {
    debugPrint('ℹ️ Mood check-in skipped');
    Navigator.of(context).pop();
    if (widget.onSkip != null) {
      widget.onSkip!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: ModernAppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _isSaving
                ? Container(
                    padding: const EdgeInsets.all(40),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: ModernAppColors.vibrantCyan,
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: ModernAppColors.primaryGradient,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.mood_rounded,
                              color: ModernAppColors.lightText,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'How are you today?',
                                style: TextStyle(
                                  color: ModernAppColors.lightText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: ModernAppColors.lightText,
                                size: 22,
                              ),
                              onPressed: _skip,
                              tooltip: 'Skip',
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Mood Level Selection
                              const Text(
                                'Rate your day',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ModernAppColors.lightText,
                                ),
                              ),
                              const SizedBox(height: 16),
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
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? mood['color'].withOpacity(0.3)
                                            : ModernAppColors.darkBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? mood['color']
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            mood['emoji'],
                                            style: const TextStyle(fontSize: 24),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            mood['label'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: ModernAppColors.lightText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 20),

                              // Emotions Selection (optional, compact)
                              const Text(
                                'How are you feeling? (optional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ModernAppColors.mutedText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                alignment: WrapAlignment.center,
                                children: _emotions.entries.map((entry) {
                                  final isSelected =
                                      _selectedEmotions.contains(entry.key);
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
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? ModernAppColors.vibrantCyan
                                                .withOpacity(0.2)
                                            : ModernAppColors.darkBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? ModernAppColors.vibrantCyan
                                              : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            entry.value,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            entry.key,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: ModernAppColors.lightText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 20),

                              // Save Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _selectedMoodLevel != null
                                      ? _saveMood
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedMoodLevel != null
                                        ? ModernAppColors.vibrantCyan
                                        : ModernAppColors.mutedText,
                                    disabledBackgroundColor:
                                        ModernAppColors.mutedText,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: _selectedMoodLevel != null ? 4 : 0,
                                  ),
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ModernAppColors.lightText,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
