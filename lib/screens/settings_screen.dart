import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/modern_colors.dart';
import '../models/water_model.dart';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  String? _username;
  String? _email;
  bool _medicationRemindersEnabled = true;
  bool _waterRemindersEnabled = true;
  int _waterGoal = 2500;
  bool _isLoading = true;
  late AnimationController _floatController;
  
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }
  Future<void> _loadUserData() async {
    final user = _authService.getCurrentUser();
    final username = await _authService.fetchUsername();
    setState(() {
      _username = username ?? 'User';
      _email = user?.email ?? '';
      _isLoading = false;
    });
  }
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _medicationRemindersEnabled = prefs.getBool('medication_reminders') ?? true;
      _waterGoal = prefs.getInt('water_goal') ?? 2500;
    });
    
    if (mounted) {
      final waterModel = Provider.of<WaterModel>(context, listen: false);
      if (_waterGoal != waterModel.dailyGoal) {
        await waterModel.setDailyGoal(_waterGoal);
      }
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }
  
  /// Save notification preference to Firebase
  Future<void> _saveNotificationPreference(String key, bool value) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    try {
      await _database.ref('users/$userId/notificationPreferences/$key').set(value);
      debugPrint('✅ [Settings] Saved $key: $value');
    } catch (e) {
      debugPrint('❌ [Settings] Failed to save notification preference: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save notification settings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernAppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: ModernAppColors.lightText),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: ModernAppColors.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ModernAppColors.mutedText),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: ModernAppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: ModernAppColors.lightText),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ModernAppColors.darkBg,
        body: const Center(
          child: CircularProgressIndicator(
            color: ModernAppColors.vibrantCyan,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ModernAppColors.darkBg,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Header
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ModernAppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Profile Card
                  _buildProfileCard(),
                  const SizedBox(height: 25),
                  // Settings sections
                  _buildSettingsSection(),
                  const SizedBox(height: 25),
                  // Preferences
                  _buildPreferencesSection(),
                  const SizedBox(height: 25),
                  // About section
                  _buildAboutSection(),
                  const SizedBox(height: 25),
                  // Logout button
                  _buildLogoutButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
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
              top: 150 + (_floatController.value * 50),
              right: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ModernAppColors.accentPink.withOpacity(0.2),
                      ModernAppColors.accentPink.withOpacity(0.0),
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

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            child: const Icon(
              Icons.person_rounded,
              color: ModernAppColors.lightText,
              size: 35,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username ?? 'User',
                  style: const TextStyle(
                    color: ModernAppColors.lightText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email ?? '',
                  style: TextStyle(
                    color: ModernAppColors.lightText.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    initialUsername: _username ?? '',
                    initialEmail: _email ?? '',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.edit_rounded,
              color: ModernAppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 15),
        _buildSwitchTile(
          icon: Icons.medication_rounded,
          title: 'Medication Reminders',
          subtitle: 'Get notified for medications',
          color: ModernAppColors.accentOrange,
          value: _medicationRemindersEnabled,
          onChanged: (value) async {
            setState(() {
              _medicationRemindersEnabled = value;
            });
            await _saveNotificationPreference('medicationReminders', value);
            
            // 🔔 Reschedule or cancel notifications
            if (value) {
              await NotificationService().scheduleAllMedicationNotifications();
            } else {
              // Cancel all medication notifications
              // Note: We can't cancel all at once without IDs, so we reschedule which will check preferences
              await NotificationService().scheduleAllMedicationNotifications();
            }
          },
        ),
        const SizedBox(height: 10),
        _buildSwitchTile(
          icon: Icons.water_drop_rounded,
          title: 'Water Reminders',
          subtitle: 'Get notified to stay hydrated',
          color: ModernAppColors.vibrantCyan,
          value: _waterRemindersEnabled,
          onChanged: (value) async {
            setState(() {
              _waterRemindersEnabled = value;
            });
            await _saveNotificationPreference('waterReminders', value);
            
            // 🔔 Reschedule or cancel notifications
            if (value) {
              await NotificationService().scheduleWaterReminders();
            } else {
              await NotificationService().cancelAllWaterReminders();
            }
          },
        ),
        const SizedBox(height: 10),
        _buildSettingsTile(
          icon: Icons.water_drop_rounded,
          title: 'Water Goal',
          subtitle: '$_waterGoal ml',
          color: ModernAppColors.vibrantCyan,
          onTap: () => _showWaterGoalDialog(),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 15),
        _buildSettingsTile(
          icon: Icons.language_rounded,
          title: 'Language',
          subtitle: 'English',
          color: ModernAppColors.accentGreen,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _buildSettingsTile(
          icon: Icons.palette_rounded,
          title: 'Theme',
          subtitle: 'Dark Mode',
          color: ModernAppColors.deepPurple,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ModernAppColors.lightText,
          ),
        ),
        const SizedBox(height: 15),
        _buildSettingsTile(
          icon: Icons.help_rounded,
          title: 'Help Center',
          subtitle: 'Get support',
          color: ModernAppColors.vibrantCyan,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildSettingsTile(
          icon: Icons.privacy_tip_rounded,
          title: 'Privacy Policy',
          subtitle: 'Read our policy',
          color: ModernAppColors.accentPink,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ModernAppColors.cardBg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: ModernAppColors.lightText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: ModernAppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: ModernAppColors.mutedText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernAppColors.cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ModernAppColors.lightText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: ModernAppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ModernAppColors.vibrantCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernAppColors.error.withOpacity(0.8),
            ModernAppColors.accentPink,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: ModernAppColors.lightText),
            SizedBox(width: 10),
            Text(
              'Sign Out',
              style: TextStyle(
                color: ModernAppColors.lightText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWaterGoalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempGoal = _waterGoal;
        return AlertDialog(
          backgroundColor: ModernAppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Set Water Goal',
            style: TextStyle(color: ModernAppColors.lightText),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tempGoal ml',
                    style: const TextStyle(
                      color: ModernAppColors.vibrantCyan,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: tempGoal.toDouble(),
                    min: 1000,
                    max: 5000,
                    divisions: 40,
                    activeColor: ModernAppColors.vibrantCyan,
                    inactiveColor: ModernAppColors.mutedText.withOpacity(0.2),
                    onChanged: (value) {
                      setState(() {
                        tempGoal = value.round();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: ModernAppColors.mutedText),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: ModernAppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _waterGoal = tempGoal;
                  });
                  _saveSetting('water_goal', tempGoal);
                  Provider.of<WaterModel>(context, listen: false)
                      .setDailyGoal(tempGoal);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: ModernAppColors.lightText),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
