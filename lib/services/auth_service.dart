// 📁 lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🌟 ÇÖZÜM: Database URL'ini doğrudan belirterek bölgesel uyuşmazlık hatası giderildi.
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(), // Eğer app'i belirtmek gerekirse
      databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  // ----------------------------------------------------
  // 1. KAYIT İŞLEMİ (Sign Up)
  // ----------------------------------------------------

  // Sadece username, email ve password alır (UI'a uyumlu)
  Future<void> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // 1. ADIM: Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        // 2. ADIM: REALTIME DATABASE'e kullanıcı verilerini kaydetme
        // Path: users/{user.uid}
        await _database.ref().child('users').child(user.uid).set({
          'uid': user.uid,
          'username': username.trim(),
          'email': email.trim(),
          // Realtime Database sunucu zamanı
          'createdAt': ServerValue.timestamp,
        });
      }

      debugPrint('Kayıt Başarılı: UID ${user?.uid}');

    } on FirebaseAuthException catch (e) {
      // Hata Yönetimi
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Bu e-posta adresi zaten kayıtlı.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Geçersiz e-posta formatı.';
      } else {
        errorMessage = 'Kayıt başarısız oldu. Hata: ${e.message}';
      }
      debugPrint('AUTH HATA: $errorMessage');
      throw errorMessage;

    } catch (e) {
      debugPrint('GENEL HATA: $e');
      throw 'Kayıt sırasında beklenmedik bir hata oluştu.';
    }
  }

  // ----------------------------------------------------
  // 2. GİRİŞ İŞLEMİ (Sign In)
  // ----------------------------------------------------
  Future<void> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      debugPrint('Giriş Başarılı.');

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'E-posta veya şifre hatalı.';
      } else {
        errorMessage = 'Giriş başarısız oldu. Hata: ${e.message}';
      }
      debugPrint('GİRİŞ HATA: $errorMessage');
      throw errorMessage;

    } catch (e) {
      throw 'Giriş sırasında beklenmedik bir hata oluştu.';
    }
  }

  // ----------------------------------------------------
  // 3. OTURUM DURUMU (Stream)
  // ----------------------------------------------------
  Stream<User?> get user => _auth.authStateChanges();
}