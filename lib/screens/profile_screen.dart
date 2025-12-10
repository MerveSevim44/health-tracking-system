// 📁 lib/screens/profile_screen.dart (Sadeleştirilmiş Başlık)

import 'package:flutter/material.dart';
import 'package:health_care/theme/app_theme.dart';
import '../services/auth_service.dart';

// 🔥 PEMBE TONLAR VE BUTON RENKLERİ
const Color _lightBackground = Color(0xFFFEEAFA); // Ana Arka Plan (feeafa)
const Color _pastelPinkLight = Color(0xFFFFE5EC); // Form Alanı Arka Planı (ffe5ec)
const Color _pastelPinkMedium = Color(0xFFFFC2D1); // Gradyan/Çerçeve (ffc2d1)
const Color _buttonBlue = Color(0xFFff7ea0); // button pembe tonuna eşlendi
const Color _buttonRed = Color(0xFFff0a54); // 'Hesabı Sil' butonu

// 🔥 GRADYAN RENKLERİ KALDIRILDI, SADECE TANIMLARI KALDI (Kullanılmıyor)
// const Color _gradientTop = Color(0xFFC97C99);
// const Color _gradientBottom = Color(0xFFFFC2D1);

// YAPI DEĞİŞİMİ: StatefulWidget
class ProfileScreen extends StatefulWidget {
  final String? username;
  const ProfileScreen({super.key, this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 🔥 Controllers tanımlandı
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _initialEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Veri yükleme işlemini başlat
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🔥 YEREL VERİ ÇEKME VE BAŞLANGIÇ AYARLAMA (Aynı kalır)
  Future<void> _loadProfileData() async {
    final authService = AuthService();
    final currentUser = authService.getCurrentUser();

    // 1. E-posta
    _initialEmail = currentUser?.email;

    // 2. Kullanıcı Adı (Yerel Depolamadan çekilir)
    String? localUsername = await authService.getLocalUsername();

    if (localUsername == null) {
      localUsername = await authService.fetchAndSaveInitialUsername();
    }

    if (mounted) {
      setState(() {
        _usernameController.text = localUsername ?? widget.username ?? 'Misafir';
        _emailController.text = _initialEmail ?? 'E-posta adresi yok';
        _passwordController.text = '';
        _isLoading = false;
      });
    }
  }

  // 🔥 PROFİLİ DÜZENLE BUTONU İŞLEVİ (Aynı kalır)
  Future<void> _updateLocalProfile() async {
    setState(() => _isLoading = true);

    try {
      final newUsername = _usernameController.text;

      // Kullanıcı Adını Yerel Depolamaya Kaydet
      await AuthService().saveLocalUsername(newUsername);

      // Şifre simülasyonu
      if (_passwordController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifre güncelleme mantığı simüle edildi.'), backgroundColor: Color(0xFFC97C99)),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil bilgileri kaydedildi!'), backgroundColor: Color(0xFFC97C99)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt başarısız'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // OTURUMU KAPATMA VE ÇIKIŞ DİYALOĞU (Aynı kalır)
  Future<void> _handleSignOut(BuildContext context) async { /* ... */ }
  void _showLogoutDialog(BuildContext context) { /* ... */ }

  // SOFT TEXT FIELD (Aynı kalır)
  Widget _buildSoftTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool isPassword = false,
    bool readOnly = false,
    IconData? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: _pastelPinkLight.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _pastelPinkMedium.withOpacity(0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            offset: const Offset(-2, -2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: _pastelPinkMedium.withOpacity(0.15),
            offset: const Offset(2, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: TextField(
        readOnly: readOnly,
        controller: controller,
        obscureText: isPassword,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMedium),
          prefixIcon: Icon(prefixIcon, color: AppColors.textMedium, size: 20),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: AppColors.textLight, size: 20)
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _lightBackground,
        body: Center(child: CircularProgressIndicator(color: _pastelPinkMedium)),
      );
    }

    // 🔥 headerHeight KALDIRILDIĞI İÇİN ARTIK KULLANILMIYOR
    // final double headerHeight = MediaQuery.of(context).size.height * 0.35;

    return Scaffold(
      backgroundColor: _lightBackground,
      // 🔥 APP BAR ARTIK Scaffold'un App Bar'ı olarak tanımlandı
      appBar: AppBar(
        backgroundColor: _lightBackground,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayarlar açılıyor...')),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView( // Stack yapısı kaldırıldı
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // örnek Profil İkonu
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _pastelPinkLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: _pastelPinkMedium, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 70, color: AppColors.textDark),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: _pastelPinkMedium,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            const SizedBox(height: 30),

            // 4. BASİTLEŞTİRİLMİŞ FORM ALANLARI

            // Kullanıcı Adı
            _buildSoftTextField(
              controller: _usernameController,
              label: 'Kullanıcı Adı',
              prefixIcon: Icons.person_outline,
              suffixIcon: Icons.close,
              readOnly: _isLoading,
            ),

            // E-posta (Salt Okunur - KAPALI)
            _buildSoftTextField(
              controller: _emailController,
              label: 'Email (Değiştirilemez)',
              prefixIcon: Icons.email_outlined,
              readOnly: true,
              suffixIcon: Icons.lock_outline,
            ),

            // Şifre
            _buildSoftTextField(
              controller: _passwordController,
              label: 'Şifre Değiştir',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              readOnly: _isLoading,
              suffixIcon: Icons.visibility_off_outlined,
            ),


            const SizedBox(height: 30),


            // 5. Butonlar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateLocalProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Değişimleri Kaydet',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: TextButton(
                onPressed: _isLoading ? null : () => _showLogoutDialog(context),
                style: TextButton.styleFrom(
                  foregroundColor: _buttonRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(0),
                ),
                child: Text(
                  'Hesaptan Çıkış Yap',
                  style: AppTextStyles.labelLarge.copyWith(color: _buttonRed, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}