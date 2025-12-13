// 📁 lib/screens/auth_wrapper.dart
// Wrapper to handle mood check-in after login

import 'package:flutter/material.dart';
import 'package:health_care/widgets/mood_checkin_dialog.dart';
import 'package:health_care/screens/pastel_home_navigation.dart';
import 'package:health_care/services/mood_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isChecking = true;
  bool _showMoodCheckin = false;

  @override
  void initState() {
    super.initState();
    _checkDailyMood();
  }

  Future<void> _checkDailyMood() async {
    try {
      debugPrint('🔍 Checking today mood...');
      final moodService = MoodService();
      final todayMood = await moodService.getTodayMood();

      if (!mounted) return;

      // Check if mood was logged today
      if (todayMood == null) {
        debugPrint('❌ No mood for today → redirecting to MoodCheckinScreen');
        setState(() {
          _showMoodCheckin = true;
          _isChecking = false;
        });
      } else {
        debugPrint('✅ Today mood found (ID: ${todayMood.id})');
        setState(() {
          _showMoodCheckin = false;
          _isChecking = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error checking mood: $e');
      debugPrint('Stack trace: $stackTrace');
      // On error, show mood check-in screen
      if (!mounted) return;
      setState(() {
        _showMoodCheckin = true;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show home navigation first
    Widget homeNav = const PastelHomeNavigation();

    // If mood check-in needed, show it as a modal dialog
    if (_showMoodCheckin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showMoodCheckinDialog(context);
        }
      });
    }

    return homeNav;
  }

  void _showMoodCheckinDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must select mood
      builder: (dialogContext) => MoodCheckinDialog(
        onComplete: () {
          Navigator.of(dialogContext).pop(); // Close dialog
          if (mounted) {
            setState(() {
              _showMoodCheckin = false;
            });
          }
        },
        onSkip: () {
          Navigator.of(dialogContext).pop(); // Close dialog
          if (mounted) {
            setState(() {
              _showMoodCheckin = false;
            });
          }
        },
      ),
    );
  }
}
