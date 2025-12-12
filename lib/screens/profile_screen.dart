// 📁 lib/screens/login_screen.dart (MINOA Teması ve Animasyon Uyumu)

import 'package:flutter/material.dart';
import '../services/auth_service.dart';


// 🎨 MINOA ANA UYGULAMA RENK PALETİ
const Color primaryOrange = Color(0xFFE49B6E); // Ana Turuncu (Soft Orange)
const Color backgroundBeige = Color(0xFFFFF6EC); // Arka Plan Rengi
const Color darkTextColor = Color(0xFF5B4A3A); // Koyu Metin Rengi (Dark Text/Brown)
const Color lightSecondaryTextColor = Color(0xFF7B746E); // Açık İkincil Metin Rengi
const Color white = Colors.white;
const Color headerBackgroundColor = Color(0xFFFAE9D7); // Başlık Arka Plan Rengi


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

  // Sayfa göstergesi için durum değişkenleri (Login, akışın 3. sayfası)
  final int _currentPage = 2; // Index 2
  final int _totalPages = 3;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🌟 GİRİŞ İŞLEMİ FONKSİYONU (Navigasyon korundu)
  Future<void> _signInUser() async {
    setState(() { _isLoading = true; });

    try {
      await _authService.signInUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş başarılı! Ana sayfaya yönlendiriliyorsunuz.'),
            backgroundColor: primaryOrange, // Renk güncellendi
          ),
        );
        // 🔥 YÖNLENDİRME KORUNDU: Uygulama geçmişini temizleyerek '/home' rotasına gider.
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // 🔥 ŞİFRE SIFIRLAMA İŞLEMİ (Aynı kaldı)
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email address to reset your password.',
          ),
          backgroundColor: primaryOrange, // Renk güncellendi
        ),
      );
      return;
    }
    setState(() { _isLoading = true; });
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'The password reset link has been sent to the email address $email.',
            ),
            backgroundColor: primaryOrange, // Renk güncellendi
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
      setState(() { _isLoading = false; });
    }
  }

  // 🔥 ÖZEL TEXT ALANI (RegisterScreen ile uyumlu stil ve gölge eklendi)
  Widget _buildMinimalTextField(
      String label,
      IconData icon,
      bool isPassword,
      TextInputType keyboardType,
      TextEditingController controller,
      ) {
    return Container(
      // 🔥 GÖLGE EFEKTİ EKLENDİ
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        style: const TextStyle(color: darkTextColor), // Renk güncellendi
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryOrange), // Renk güncellendi
          filled: true,
          fillColor: white, // Renk güncellendi
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Colors.transparent, width: 0), // Çerçeve kaldırıldı
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: primaryOrange, width: 2.0), // Renk güncellendi
          ),
          labelStyle: const TextStyle(color: lightSecondaryTextColor), // Renk güncellendi
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15.0,
            horizontal: 15.0,
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // 🔥 HEADER ALANI (RegisterScreen'den kopyalandı)
  // -----------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height * 0.25,
      decoration: const BoxDecoration(
        color: headerBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange, // Başlık gölgesi
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Geri Butonu
          Positioned(
            top: 40,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: darkTextColor, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Başlık Metni
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome Back!', // Geri dönen kullanıcı için başlık
                    textAlign: TextAlign.center,
                    style: TextStyle(color: darkTextColor, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Log in to continue tracking your health.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: lightSecondaryTextColor, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // SAYFA GÖSTERGESİ FONKSİYONLARI (RegisterScreen'den kopyalandı)
  // -----------------------------------------------------------
  Widget _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _totalPages; i++) {
      list.add(_indicator(i == _currentPage));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: list,
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? darkTextColor : lightSecondaryTextColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBeige, // Renk güncellendi
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context), // MINOA temalı header

            // 🔥 TRANSFORM.TRANSLATE KULLANIMI (Görsel uyum için)
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100), // Başlık ve form arasındaki boşluk

                    // 2. GİRİŞ FORMU BÖLÜMÜ

                    _buildMinimalTextField(
                      'Email Address', // Metin güncellendi
                      Icons.email_outlined,
                      false,
                      TextInputType.emailAddress,
                      _emailController,
                    ),
                    const SizedBox(height: 20),

                    _buildMinimalTextField(
                      'Password', // Metin güncellendi
                      Icons.lock_outline,
                      true,
                      TextInputType.visiblePassword,
                      _passwordController,
                    ),

                    // Şifremi Unuttum Butonu (Renk ve hizalama güncellendi)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        child: Text(
                          'Forgot Password?', // Metin güncellendi
                          style: TextStyle(
                            color: primaryOrange, // Renk güncellendi
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Giriş Yap Butonu (Stil güncellendi)
                    SizedBox(
                      width: double.infinity,
                      height: 55, // Yükseklik RegisterScreen ile aynı
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signInUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange, // Renk güncellendi
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Radius güncellendi
                          ),
                          elevation: 8, // Gölge eklendi
                          shadowColor: primaryOrange.withOpacity(0.5),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: white)
                            : const Text(
                          'Log In', // Metin güncellendi
                          style: TextStyle(
                            color: white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 3. Kayıt Ol Yönlendirme Bölümü (Stil ve Navigasyon güncellendi)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?', // Metin güncellendi
                          style: TextStyle(color: darkTextColor.withOpacity(0.7)), // Renk güncellendi
                        ),
                        TextButton(
                          onPressed: () {
                            // 🔥 ANİMASYONLU GEÇİŞ İÇİN ROTA KULLANIMI
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            'Sign Up', // Metin güncellendi
                            style: TextStyle(
                              color: primaryOrange, // Renk güncellendi
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Sayfa Göstergesi (En altta)
                    const SizedBox(height: 20),
                    _buildPageIndicator(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
