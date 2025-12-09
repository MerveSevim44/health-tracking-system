import 'package:flutter/material.dart';

const Color primaryGreen = Color(0xFF009000); // Kullanıcının istediği ana renk
const Color lightBackground = Colors.white; // Genel Beyaz arka plan
const Color lightCardColor = Color(
  0xFFF5F5F5,
); // Hafif gri kart/input arka planı
const Color darkText = Colors.black; // Koyu metin rengi
const Color greyText = Color(0xFF757575); // Açık temaya uygun gri metin

final ThemeData appTheme = ThemeData(
  // 1. Temel Ayarlar
  useMaterial3: true, // Modern Material 3 tasarımını etkinleştirme
  brightness: Brightness.light,
  primaryColor: primaryGreen,
  scaffoldBackgroundColor: lightBackground,

  // 2. Renk Şeması (ThemeData'nın modern yolu)
  colorScheme: ColorScheme.light(
    primary: primaryGreen, // Ana renk (Yeşil)
    secondary: primaryGreen.withOpacity(0.7), // İkincil renk (Hafif Yeşil)
    background: lightBackground,
    surface: lightCardColor, // Kartlar ve yüzeyler için hafif gri
    onBackground: darkText,
  ),

  // 3. AppBar Teması
  appBarTheme: const AppBarTheme(
    backgroundColor: lightBackground,
    elevation: 0,
    scrolledUnderElevation: 0, // Material 3 altında kaydırma gölgesini kaldırır
    titleTextStyle: TextStyle(
      color: darkText,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: darkText),
  ),

  // 4. ElevatedButton Teması
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),

  // 5. Input (TextField) Teması
  inputDecorationTheme: InputDecorationTheme(
    fillColor: lightCardColor,
    filled: true,
    hintStyle: const TextStyle(color: greyText),
    labelStyle: const TextStyle(color: darkText),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),

  // 6. BottomNavigationBar Teması
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: lightBackground,
    selectedItemColor: primaryGreen,
    unselectedItemColor: greyText,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
  ),

  // 7. Genel Metin Teması
  // ColorScheme'dan renk alması için basit Theme.of(context).colorScheme kullanımı tercih edilir.
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: darkText),
    bodyMedium: TextStyle(color: darkText),
    titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
  ),
);
