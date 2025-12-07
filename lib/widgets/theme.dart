import 'package:flutter/material.dart';

// Ana Renk Paletleri
const Color primaryGreen = Color(0xFF009000); // Kullanıcının istediği ana renk
const Color lightBackground = Colors.white; // <<< GÜNCELLENDİ: Beyaz arka plan
const Color lightCardColor = Color(0xFFF5F5F5); // Hafif gri kart/input arka planı
const Color darkText = Colors.black; // <<< GÜNCELLENDİ: Koyu metin rengi
const Color greyText = Color(0xFF757575); // Açık temaya uygun gri metin

// Uygulamanın Açık Teması
final ThemeData appTheme = ThemeData(
  // 1. Ana Renkler
  brightness: Brightness.light, // <<< GÜNCELLENDİ: Açık tema parlaklığı
  primaryColor: primaryGreen, // Yeşil vurgu
  scaffoldBackgroundColor: lightBackground, // Genel arka plan beyaz

  // 2. AppBar Teması
  appBarTheme: const AppBarTheme(
    backgroundColor: lightBackground, // AppBar rengi beyaz
    elevation: 0,
    titleTextStyle: TextStyle(
      color: darkText, // Başlık metni siyah
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: darkText), // İkonlar siyah
  ),

  // 3. Buton Teması
  // NOT: Sohbet butonu özel bir Container/IconButton olarak ele alındığı için buradaki temayı etkilemez.
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen, // Yeşil buton arka planı
      foregroundColor: Colors.white, // Buton metin rengi beyaz (yeşil üzerinde)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
  ),

  // 4. Input (TextField) Teması
  inputDecorationTheme: InputDecorationTheme(
    fillColor: lightCardColor, // Hafif gri input arka planı
    filled: true,
    hintStyle: const TextStyle(color: greyText),
    labelStyle: const TextStyle(color: darkText),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),

  // 5. BottomNavigationBar Teması
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: lightBackground, // Alt bar beyaz
    selectedItemColor: primaryGreen, // Seçili ikon yeşil
    unselectedItemColor: greyText, // Seçili olmayan ikon gri
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
  ),

  // 6. Genel Metin Teması
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: darkText),
    bodyMedium: TextStyle(color: darkText),
    titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
  ).apply(
    bodyColor: darkText,
    displayColor: darkText,
  ),
);