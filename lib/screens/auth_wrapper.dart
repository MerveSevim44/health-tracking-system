// 📁 lib/screens/auth_wrapper.dart
// Login sonrası mood kontrolü - Günde 1-2 kere gösterilir

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mood_checkin_screen.dart';
import 'pastel_home_navigation.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _shouldShowMoodCheckin = false;

  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  @override
  void initState() {
    super.initState();
    _checkMoodStatus();
  }

  Future<void> _checkMoodStatus() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Check if today's mood exists using the new structure: moods/{uid}/{YYYY-MM-DD}
      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      // Check if mood entry exists for today
      final moodRef = _database.ref('moods/$userId/$todayKey');
      final snapshot = await moodRef.get();
      
      // If today's mood exists, don't show the check-in screen
      final shouldShow = !snapshot.exists;
      
      debugPrint('📊 Mood Check: Today=$todayKey, Exists=${snapshot.exists}, ShouldShow=$shouldShow');
      
      setState(() {
        _shouldShowMoodCheckin = shouldShow;
        _isLoading = false;
      });
      
    } catch (e) {
      debugPrint('❌ Error checking mood status: $e');
      setState(() {
        _shouldShowMoodCheckin = true; // Show on error
        _isLoading = false;
      });
    }
  }

  void _onMoodComplete() {
    debugPrint('✅ Mood check-in completed, navigating to home');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PastelHomeNavigation()),
    );
  }

  void _onMoodSkip() {
    debugPrint('⏭️ Mood check-in skipped, navigating to home');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PastelHomeNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF9F0),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFD93D),
          ),
        ),
      );
    }

    // Mood check-in gösterilmeli mi?
    if (_shouldShowMoodCheckin) {
      return MoodCheckinScreen(
        onComplete: _onMoodComplete,
        onSkip: _onMoodSkip,
      );
    }

    // Direkt ana sayfaya git
    return const PastelHomeNavigation();
  }
}
