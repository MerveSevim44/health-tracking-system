// 📁 lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
// 🔥 YENİ: Shared Preferences importu eklendi
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ÇÖZÜM: Database URL'ini doğrudan belirterek bölgesel uyuşmazlık hatası giderildi.
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://health-tracking-system-700bf-default-rtdb.europe-west1.firebasedatabase.app"
  );

  // ----------------------------------------------------
  // 4. KULLANICI ADINI ÇEKME METODU
  // ----------------------------------------------------
  Future<String?> fetchUsername() async {
// ... (Mevcut kod aynı kalır)
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final dataSnapshot = await _database.ref()
          .child('users')
          .child(user.uid)
          .child('username')
          .get();

      if (dataSnapshot.exists && dataSnapshot.value != null) {
        return dataSnapshot.value as String?;
      }
      return null;

    } catch (e) {
      debugPrint('Kullanıcı adı çekilemedi: $e');
      return null;
    }
  }

  // ----------------------------------------------------
  // 5. CURRENT USER ALMA METODU
  // ----------------------------------------------------
  /// Firebase Auth'ta şu anda oturum açmış olan User nesnesini döndürür.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ----------------------------------------------------
  // 1. KAYIT İŞLEMİ (Sign Up)
  // ----------------------------------------------------
// ... (Mevcut kod aynı kalır)
  Future<void> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        await _database.ref().child('users').child(user.uid).set({
          'uid': user.uid,
          'username': username.trim(),
          'email': email.trim(),
          'createdAt': ServerValue.timestamp,
        });
      }

      debugPrint('Kayıt Başarılı: UID ${user?.uid}');

    } on FirebaseAuthException catch (e) {
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
// ... (Mevcut kod aynı kalır)
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
  // 6. ŞİFRE SIFIRLAMA İŞLEMİ
  // ----------------------------------------------------
// ... (Mevcut kod aynı kalır)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      debugPrint('Şifre sıfırlama e-postası $email adresine gönderildi.');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Bu e-posta adresi ile kayıtlı bir kullanıcı bulunamadı.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Lütfen geçerli bir e-posta adresi girin.';
      } else {
        errorMessage = 'Şifre sıfırlama başarısız oldu. Hata: ${e.message}';
      }
      debugPrint('ŞİFRE SIFIRLAMA HATA: $errorMessage');
      throw errorMessage;
    } catch (e) {
      throw 'Şifre sıfırlama sırasında beklenmedik bir hata oluştu.';
    }
  }

  // ----------------------------------------------------
  // 7. OTURUMU KAPATMA İŞLEMİ
  // ----------------------------------------------------
// ... (Mevcut kod aynı kalır)
  Future<void> signOut() async {
    try {
      // Firebase Auth üzerinden çıkış yapılır
      await _auth.signOut();
      debugPrint('Kullanıcı çıkış yaptı.');
    } catch (e) {
      debugPrint('Çıkış hatası: $e');
      // Hatanın uygulama arayüzünde görünmesi için fırlatılır
      throw 'Oturumu kapatırken bir hata oluştu: $e';
    }
  }

  // ----------------------------------------------------
  // 3. OTURUM DURUMU (Stream)
  // ----------------------------------------------------
  Stream<User?> get user => _auth.authStateChanges();

  // ----------------------------------------------------
  // 8. YEREL DEPOLAMA METOTLARI (YENİ EKLENDİ)
  // ----------------------------------------------------

  /// Kullanıcı adını yerel depolamadan getirir.
  Future<String?> getLocalUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('local_username');
  }

  /// Kullanıcı adını yerel depolamaya kaydeder.
  Future<void> saveLocalUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_username', username);
  }

  /// Firebase'den çektiği ilk kullanıcı adını yerel depolamaya kaydeder (Sadece ilk çalıştırmada veya yerel veri yoksa)
  Future<String?> fetchAndSaveInitialUsername() async {
    final firebaseUsername = await fetchUsername(); // Mevcut Firebase metodunu kullan
    if (firebaseUsername != null) {
      await saveLocalUsername(firebaseUsername); // Yerel depoya kaydet
      return firebaseUsername;
    }
    return null;
  }
}