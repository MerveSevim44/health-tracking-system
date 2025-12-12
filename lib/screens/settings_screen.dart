// 📁 lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/water_model.dart';

// 🎨 SETTINGS SCREEN RENK PALETİ (Light Pastel Theme)
class SettingsColors {
  static const Color background = AppColors.background; // Color(0xFFFBFBFB)
  static const Color cardBackground = AppColors.cardBackground; // Colors.white
  static const Color primaryGreen = AppColors.moodCalm; // Color(0xFF06D6A0)
  static const Color textDark = AppColors.textDark; // Color(0xFF2D3436)
  static const Color textMedium = AppColors.textMedium; // Color(0xFF636E72)
  static const Color textLight = AppColors.textLight; // Color(0xFFB2BEC3)
  static const Color red = AppColors.moodAnxious; // Color(0xFFEF476F)
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  String? _username;
  String? _email;
  bool _medicationRemindersEnabled = true;
  int _waterGoal = 2500; // ml
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  Future<void> _loadUserData() async {
    final user = _authService.getCurrentUser();
    final username = await _authService.fetchUsername();
    
    setState(() {
      _username = username ?? 'Kullanıcı';
      _email = user?.email ?? '';
      _isLoading = false;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _medicationRemindersEnabled = prefs.getBool('medication_reminders') ?? true;
      // SharedPreferences'tan al, yoksa 2500
      _waterGoal = prefs.getInt('water_goal') ?? 2500;
    });
    
    // WaterModel'i de senkronize et
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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SettingsColors.cardBackground,
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(color: SettingsColors.textDark),
        ),
        content: const Text(
          'Çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(color: SettingsColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'İptal',
              style: TextStyle(color: SettingsColors.textMedium),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: SettingsColors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          // StreamBuilder in main.dart will handle navigation
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Çıkış yapılırken hata: $e'),
              backgroundColor: SettingsColors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsColors.background,
      appBar: AppBar(
        backgroundColor: SettingsColors.background,
        elevation: 0,
        title: const Text(
          'Ayarlar',
          style: TextStyle(
            color: SettingsColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: SettingsColors.textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: SettingsColors.textDark),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: SettingsColors.primaryGreen,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildProfileSection(),
                  const SizedBox(height: 32),

                  // Health & Goals Section
                  _buildSectionTitle('SAĞLIK VE HEDEFLER'),
                  const SizedBox(height: 12),
                  _buildHealthGoalsCard(),
                  const SizedBox(height: 32),

                  // App Settings Section
                  _buildSectionTitle('UYGULAMA AYARLARI'),
                  const SizedBox(height: 12),
                  _buildAppSettingsCard(),
                  const SizedBox(height: 32),

                  // Support Section
                  _buildSectionTitle('DESTEK VE BİLGİ'),
                  const SizedBox(height: 12),
                  _buildSupportCard(),
                  const SizedBox(height: 32),

                  // Logout Button
                  _buildLogoutButton(),
                  const SizedBox(height: 24),

                  // Version Info
                  _buildVersionInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SettingsColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SettingsColors.textLight.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    initialUsername: _username ?? '',
                    initialEmail: _email ?? '',
                  ),
                ),
              );
              if (result == true) {
                _loadUserData();
              }
            },
            child: Stack(
              children: [
                CircleAvatar(
                radius: 40,
                backgroundColor: SettingsColors.primaryGreen.withOpacity(0.2),
                child: _username != null && _username!.isNotEmpty
                    ? Text(
                        _username![0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: SettingsColors.primaryGreen,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 40,
                        color: SettingsColors.primaryGreen,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: SettingsColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username ?? 'Kullanıcı',
                  style: const TextStyle(
                    color: SettingsColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email ?? '',
                  style: const TextStyle(
                    color: SettingsColors.textMedium,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    initialUsername: _username ?? '',
                    initialEmail: _email ?? '',
                  ),
                ),
              );
              if (result == true) {
                _loadUserData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SettingsColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
            ),
            child: const Text(
              'Profili Düzenle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: SettingsColors.textLight,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildHealthGoalsCard() {
    return Container(
      decoration: BoxDecoration(
        color: SettingsColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: SettingsColors.textLight.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.medication_liquid,
            iconColor: Colors.red,
            title: 'İlaç Hatırlatıcıları',
            trailing: Switch(
              value: _medicationRemindersEnabled,
              onChanged: (value) {
                setState(() {
                  _medicationRemindersEnabled = value;
                });
                _saveSetting('medication_reminders', value);
              },
              activeColor: SettingsColors.primaryGreen,
            ),
          ),
          Divider(
            height: 1,
            color: SettingsColors.textLight.withOpacity(0.3),
            indent: 56,
          ),
          _buildSettingItem(
            icon: Icons.water_drop,
            iconColor: Colors.blue,
            title: 'Su Hedefi',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_waterGoal ml',
                  style: const TextStyle(
                    color: SettingsColors.textMedium,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: SettingsColors.textLight,
                ),
              ],
            ),
            onTap: () {
              _showWaterGoalDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: SettingsColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: SettingsColors.textLight.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            iconColor: Colors.purple,
            title: 'Bildirimler',
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: SettingsColors.textLight,
            ),
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          Divider(
            height: 1,
            color: SettingsColors.textLight.withOpacity(0.3),
            indent: 56,
          ),
          _buildSettingItem(
            icon: Icons.language,
            iconColor: Colors.teal,
            title: 'Dil',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Türkçe',
                  style: TextStyle(
                    color: SettingsColors.textMedium,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: SettingsColors.textLight,
                ),
              ],
            ),
            onTap: () {
              // Navigate to language settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      decoration: BoxDecoration(
        color: SettingsColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: SettingsColors.textLight.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.help_outline,
            iconColor: Colors.orange,
            title: 'Yardım Merkezi',
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: SettingsColors.textLight,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterScreen(),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            color: SettingsColors.textLight.withOpacity(0.3),
            indent: 56,
          ),
          _buildSettingItem(
            icon: Icons.shield_outlined,
            iconColor: SettingsColors.primaryGreen,
            title: 'Gizlilik Politikası',
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: SettingsColors.textLight,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: SettingsColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: SettingsColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: SettingsColors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: const Text(
          'Çıkış Yap',
          style: TextStyle(
            color: SettingsColors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Text(
        'Sürüm 1.0.0 (Build 204)',
        style: TextStyle(
          color: SettingsColors.textLight,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _showWaterGoalDialog() async {
    final TextEditingController controller = TextEditingController(
      text: _waterGoal.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SettingsColors.cardBackground,
        title: const Text(
          'Su Hedefi',
          style: TextStyle(color: SettingsColors.textDark),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: SettingsColors.textDark),
          decoration: InputDecoration(
            labelText: 'Hedef (ml)',
            labelStyle: const TextStyle(color: SettingsColors.textMedium),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: SettingsColors.textLight.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: SettingsColors.primaryGreen, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: SettingsColors.background,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: SettingsColors.textMedium),
            ),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            child: const Text(
              'Kaydet',
              style: TextStyle(color: SettingsColors.primaryGreen, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _waterGoal = result;
      });
      // SharedPreferences'a kaydet (zaten _saveSetting yapıyor ama WaterModel'e de bildir)
      await _saveSetting('water_goal', result);
      
      // WaterModel'e de güncelle
      if (mounted) {
        final waterModel = Provider.of<WaterModel>(context, listen: false);
        await waterModel.setDailyGoal(result);
      }
    }
  }
}
