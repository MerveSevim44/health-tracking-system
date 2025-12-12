import 'package:flutter/material.dart';

// Belirtilen renk paletine göre Hex kodları
const Color primaryOrange = Color(0xFFE49B6E); // Ana Turuncu (Soft Orange)
const Color backgroundBeige = Color(0xFFFFF6EC); // Arka Plan Rengi
const Color darkTextColor = Color(0xFF5B4A3A); // Koyu Metin Rengi (Dark Text/Brown)
const Color lightSecondaryTextColor = Color(0xFF7B746E); // Açık İkincil Metin Rengi
const Color lightOrangeAccent = Color(0xFFF2C8A4); // Açık Turuncu Vurgu

// --------------------------------------------------------------------------------
// YARDIMCI WIDGET: FeatureCard (Aynı Kalır)
// --------------------------------------------------------------------------------
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color accentColor;

  const FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.accentColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 30,
              color: color,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: darkTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: darkTextColor.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------------
// ANA WIDGET: FirstScreen (TEK SAYFAYA DÖNÜŞTÜRÜLDÜ)
// --------------------------------------------------------------------------------
class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  // Sayfa göstergesindeki noktaları oluşturan widget (Statik görünümlü)
  Widget _buildPageIndicator() {
    const int totalPages = 3;
    const int currentPage = 0; // İlk sayfa aktif

    List<Widget> list = [];
    for (int i = 0; i < totalPages; i++) {
      list.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 8.0,
            width: i == currentPage ? 24.0 : 8.0,
            decoration: BoxDecoration(
              color: i == currentPage ? darkTextColor : lightSecondaryTextColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageAreaHeight = size.height * 0.30;

    return Scaffold(
      backgroundColor: backgroundBeige,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // İKON / GÖRSEL (minoa.png)
              Container(
                height: imageAreaHeight,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Image.asset(
                    'assets/images/minoa.png',
                    fit: BoxFit.contain,
                    height: imageAreaHeight,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Uygulama Sloganı
              const SizedBox(height: 8),
              Text(
                'AI-Powered Emotional\nWellness & Health Tracker',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: lightSecondaryTextColor,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 50),

              // Ana Özellik Kartları
              Expanded(
                child: Column(
                  children: [
                    FeatureCard(
                      icon: Icons.ssid_chart_outlined,
                      title: 'Emotional Balance',
                      description: 'Understand your AI-driven emotion analysis.',
                      color: primaryOrange,
                      accentColor: lightOrangeAccent,
                    ),
                    const SizedBox(height: 20),
                    FeatureCard(
                      icon: Icons.directions_run_outlined,
                      title: 'Healthier Lifestyle',
                      description: 'Daily activity, and effortlessly monitor your wellbeing.',
                      color: primaryOrange,
                      accentColor: lightOrangeAccent,
                    ),
                    const Spacer(), // Sayfanın altına doğru itmek için
                  ],
                ),
              ),

              // GET STARTED Butonu (DOĞRUDAN /register rotasına gider)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // 🔥 DOĞRUDAN /register rotasına animasyonlu geçiş
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: primaryOrange.withOpacity(0.4),
                  ),
                  child: const Text(
                    'GET STARTED',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Sayfa Göstergesi
              _buildPageIndicator(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
