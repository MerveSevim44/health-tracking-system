// 📁 lib/screens/login_screen.dart

import 'package:flutter/material.dart';
// 🌟 EKLENDİ: AuthService ve HomeScreen importları
import '../services/auth_service.dart';
import 'home_screen.dart'; // **ÖNEMLİ: HomeScreen dosyanızın yolunu kontrol edin**
import '../theme/curved_app_bar.dart';
import 'register_screen.dart';

// Ana uygulama renkleri (Turuncu Tema)
const Color primaryOrange = Color(0xFFFF7F00);
const Color secondaryOrange = Color(0xFFFF9933);
const Color accentOrange = Color(0xFFFF7F00);
const Color white = Colors.white;
const Color darkGrey = Color(0xFF333333);
const Color backgroundBeige = Color(0xFFFBF4EA);


// 🌟 StatelessWidget'tan StatefulWidget'a dönüştürüldü
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 🌟 Controller'lar tanımlandı
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

  // 🌟 GİRİŞ İŞLEMİ FONKSİYONU
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
          const SnackBar(content: Text('Giriş başarılı! Ana sayfaya yönlendiriliyorsunuz.'), backgroundColor: darkGrey),
        );

        // 🌟 YÖNLENDİRME: HomeScreen'e yönlendir ve geri tuşunu devre dışı bırak
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false, // Tüm önceki yolları kaldır
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


  // Özel Text Alanı Oluşturma Fonksiyonu (Controller parametresi eklendi)
  Widget _buildMinimalTextField(
      String label, IconData icon, bool isPassword, TextInputType keyboardType, TextEditingController controller) {
    return TextField(
      controller: controller, // 🌟 Controller bağlandı
      keyboardType: keyboardType,
      obscureText: isPassword,
      style: const TextStyle(color: darkGrey),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryOrange),
        filled: true,
        fillColor: Colors.grey.shade100,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: primaryOrange, width: 2.0),
        ),
        labelStyle: const TextStyle(color: darkGrey),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundBeige,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. OVAL GEÇİŞLİ ÜST BAR (CurvedAppBar Kullanımı)
            CurvedAppBar(
              heightRatio: 0.35,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Başlık
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
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hoş Geldiniz', style: TextStyle(color: darkGrey, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Hesabınıza giriş yapınız.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 30),

                  // E-posta Girişi (Controller bağlandı)
                  _buildMinimalTextField('E-posta Adresi', Icons.email_outlined, false, TextInputType.emailAddress, _emailController),
                  const SizedBox(height: 15),

                  // Şifre Girişi (Controller bağlandı)
                  _buildMinimalTextField('Şifre', Icons.lock_outline, true, TextInputType.visiblePassword, _passwordController),

                  // Şifremi Unuttum Butonu
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () { /* Şifremi Unuttum İşlemi */ },
                      child: Text('Şifremi Unuttum?', style: TextStyle(color: primaryOrange.withOpacity(0.7), fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Giriş Yap Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signInUser, // 🌟 Fonksiyon ve Loading eklendi
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: white) // Yükleniyor ikonu
                          : const Text('Giriş Yap', style: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Kayıt Ol Yönlendirme Bölümü
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Hesabın yok mu?', style: TextStyle(color: darkGrey)),
                  TextButton(
                    onPressed: () {
                      // Kayıt Ol Sayfasına Yönlendirme
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Kayıt Ol', style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold)),
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