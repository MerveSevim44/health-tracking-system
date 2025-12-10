// 📁 lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// 🔥 GÜNCELLENDİ: Ana sayfa artık PastelHomeNavigation olarak kabul ediliyor
import '../screens/pastel_home_navigation.dart'; // PastelHomeNavigation importu
import '../theme/curved_app_bar.dart';
import 'register_screen.dart';

// Health Care Teması Renkleri (Yeşil - Sağlık Temalı)
const Color primaryGreen = Color(0xFF009000); // Ana yeşil
const Color secondaryGreen = Color(0xFF4CAF50); // Açık yeşil
const Color accentGreen = Color(0xFF00C853); // Vurgulu yeşil
const Color white = Colors.white;
const Color darkText = Color(0xFF2C3E50); // Koyu metin
const Color lightBackground = Color(
  0xFFF0F9F0,
); // Açık yeşilimsi beyaz arka plan
const Color healthCardBg = Color(0xFFE8F5E9); // Sağlık kartları için açık yeşil

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🌟 GİRİŞ İŞLEMİ FONKSİYONU (Aynı Kaldı)
  Future<void> _signInUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. ADIM: AuthService ile giriş yap
      await _authService.signInUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // 2. ADIM: Başarılı yönlendirme (Uygulama geçmişini temizleyerek)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş başarılı! Ana sayfaya yönlendiriliyorsunuz.'),
            backgroundColor: primaryGreen,
          ),
        );

        // 🔥 YÖNLENDİRME: PastelHomeNavigation (main.dart'taki '/home' rotasına)
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // 3. ADIM: Hata mesajını göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🔥 YENİ EKLENDİ: ŞİFRE SIFIRLAMA İŞLEMİ
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lütfen şifrenizi sıfırlamak için e-posta adresinizi girin.',
          ),
          backgroundColor: accentGreen,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // AuthService üzerinden Firebase'e sıfırlama e-postası gönder
      await _authService.sendPasswordResetEmail(email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Şifre sıfırlama bağlantısı $email adresine gönderildi.',
            ),
            backgroundColor: primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Özel Text Alanı Oluşturma Fonksiyonu (Aynı kaldı)
  Widget _buildMinimalTextField(
    String label,
    IconData icon,
    bool isPassword,
    TextInputType keyboardType,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      style: const TextStyle(color: darkText),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryGreen),
        filled: true,
        fillColor: healthCardBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: secondaryGreen.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: primaryGreen, width: 2.0),
        ),
        labelStyle: const TextStyle(color: darkText),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 15.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. OVAL GEÇİŞLİ ÜST BAR (Aynı kaldı)
            CurvedAppBar(
              heightRatio: 0.35,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Health App',
                      style: TextStyle(
                        color: white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. GİRİŞ FORMU BÖLÜMÜ
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hoş Geldiniz',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hesabınıza giriş yapınız.',
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Sağlığınızı takip edin 🌿',
                    style: TextStyle(color: secondaryGreen, fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  _buildMinimalTextField(
                    'E-posta Adresi',
                    Icons.email_outlined,
                    false,
                    TextInputType.emailAddress,
                    _emailController,
                  ),
                  const SizedBox(height: 15),

                  _buildMinimalTextField(
                    'Şifre',
                    Icons.lock_outline,
                    true,
                    TextInputType.visiblePassword,
                    _passwordController,
                  ),

                  // 🔥 GÜNCELLENDİ: Şifremi Unuttum Butonu, _resetPassword metoduna bağlandı.
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      child: Text(
                        'Şifremi Unuttum?',
                        style: TextStyle(
                          color: primaryGreen.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Giriş Yap Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signInUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: white)
                          : const Text(
                              'Giriş Yap',
                              style: TextStyle(
                                color: white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Kayıt Ol Yönlendirme Bölümü (Aynı kaldı)
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hesabın yok mu?',
                    style: TextStyle(color: darkText),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Kayıt Ol',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
