// 📁 lib/screens/first_screen.dart (Hata Düzeltmeleri Yapıldı)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Ana uygulama renkleri
const Color primaryOrange = Color(0xFFFF7F00); // Ana turuncu renk
const Color secondaryOrange = Color(0xFFFF9933);
const Color backgroundBeige = Color(0xFFFBF4EA);
const Color textColor = Color(0xFF333333);
const Color white = Colors.white;

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      // Try to sign in with test email first (create if not exists)
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: 'test@test.com',
          password: 'test123',
        );
      } catch (e) {
        // If user doesn't exist, create it
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'test@test.com',
          password: 'test123',
        );
      }
      
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş hatası: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundBeige,
      body: SafeArea(
        child: Column(
          children: [
            // 1. OVAL ÜST BAR (Turuncu Gradyan ve AI Robot İKONU)
            Container(
              width: size.width,
              height: size.height * 0.60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryOrange,
                    secondaryOrange,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Center(
                // HATA DÜZELTME: Center'ın child'ı Column olmalı.
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // AI Robot İKONU (SizedBox ikonun içinde DEĞİL, hemen altında olmalı)
                    Image.asset(
                      'assets/images/ai_robot.png',
                      width: size.width * 0.65,
                      height: size.width * 0.70,
                      fit: BoxFit.contain,
                    ),

                    // Uygulama Adı EKLENDİ (Şimdi Column'un doğru bir child'ı)
                    const Text(
                      'App',
                      style: TextStyle(
                        color: white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. ALT GÖVDE VE BUTONLAR BÖLÜMÜ
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Başlık ve Açıklama Metni
                    Column(
                      children: [
                        // HATA DÜZELTME: Boşluk 10'a düşürüldü, çünkü üst bar alanı artık daha az.
                        const SizedBox(height: 20),
                        Text(
                          'Yapay zeka Destekli Sağlık Takip Sistemimiz Sizlerle!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Daha fazla bilgi ve detaylar için hemen kayıt olun.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    // SADECE KAYIT OL BUTONU
                    Column(
                      children: [
                        // Create account Butonu (Ana eylem)
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () => _signInAnonymously(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Başlayın',
                              style: TextStyle(
                                color: white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
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