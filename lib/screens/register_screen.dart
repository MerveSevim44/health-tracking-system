// 📁 lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/curved_app_bar.dart'; // CurvedAppBar importu
import 'login_screen.dart';

// Ana uygulama renkleri (Turuncu Tema)
const Color primaryOrange = Color(0xFFFF7F00);
const Color secondaryOrange = Color(0xFFFF9933);
const Color accentOrange = Color(0xFFFF7F00);
const Color white = Colors.white;
const Color darkGrey = Color(0xFF333333);
const Color backgroundBeige = Color(0xFFFBF4EA);


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🌟 Kayıt İşlemi Fonksiyonu (Realtime DB'ye yazar)
  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // İş mantığını servise devret
      await _authService.registerUser(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Başarılı yönlendirme ve geri bildirim
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı! Giriş sayfasına yönlendiriliyorsunuz.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  // Özel Text Alanı Oluşturma Fonksiyonu (Aynı kalır)
  Widget _buildMinimalTextField(
      String label, IconData icon, bool isPassword, TextInputType keyboardType, TextEditingController controller) {
    return TextField(
      controller: controller,
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
    return Scaffold(
      backgroundColor: backgroundBeige,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🌟 EKLENDİ: 1. OVAL GEÇİŞLİ ÜST BAR (CurvedAppBar Kullanımı)
            CurvedAppBar(
              heightRatio: 0.25, // Oranı korundu
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Gelişmeleri Takip Etmek için Hesap Oluştur',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // 2. KAYIT FORMU ALANI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hemen Katılın!', style: TextStyle(color: darkGrey, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Günlük aktivitelerinizi kolaylaştırmak için burdayız...', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 30),

                  // Kullanıcı Adı Girişi
                  _buildMinimalTextField('Kullanıcı Adı', Icons.person_outline, false, TextInputType.name, _usernameController),
                  const SizedBox(height: 15),

                  // E-posta Girişi
                  _buildMinimalTextField('E-posta Adresi', Icons.email_outlined, false, TextInputType.emailAddress, _emailController),
                  const SizedBox(height: 15),

                  // Şifre Girişi
                  _buildMinimalTextField('Şifre', Icons.lock_outline, true, TextInputType.visiblePassword, _passwordController),
                  const SizedBox(height: 30),

                  // Kayıt Ol Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: white)
                          : const Text('Hesap Oluştur', style: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // Giriş Yap Text Butonu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Zaten hesabın var mı?', style: TextStyle(color: darkGrey)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Giriş Yap',
                          style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
