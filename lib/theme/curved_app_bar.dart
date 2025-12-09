// 📁 lib/widgets/curved_app_bar.dart (Turuncu Temaya Uyarlanmıştır)

import 'package:flutter/material.dart';

// Turuncu Tema Renkleri
const Color primaryOrange = Color(0xFFFF7F00); // Ana turuncu
const Color secondaryOrange = Color(0xFFFF9933); // Gradyan için açık turuncu
const Color white = Colors.white;

class CurvedAppBar extends StatelessWidget {
  final Widget? child;
  final double heightRatio; // Ekran yüksekliğinin kaplanacak oranı (Örn: 0.35)
  final double borderRadiusValue; // Alt kenar ovalleşme değeri

  const CurvedAppBar({
    super.key,
    required this.heightRatio,
    this.child,
    this.borderRadiusValue = 50.0, // Varsayılan ovalleşme 50.0
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height * heightRatio,
      decoration: BoxDecoration(
        // Geçişli Turuncu Renk
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryOrange, secondaryOrange], // TURUNCU Gradyan
        ),
        // Oval Kenarlar
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadiusValue),
          bottomRight: Radius.circular(borderRadiusValue),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4), // Hafif gölge
          ),
        ],
      ),
      child: SafeArea(
        // Hata koruması için null kontrolü
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}