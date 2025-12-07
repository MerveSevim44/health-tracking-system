import 'package:flutter/material.dart';
import 'package:health_care/widgets/theme.dart'; // Tema sabitlerini kullanmak için (greyText vb.)

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> with TickerProviderStateMixin {

  // Nefes döngüsü animasyonu (Büyüyüp küçülen daire)
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Kronometre kontrolcüsü (Geri sayım)
  late AnimationController _timerController;

  // Varsayılan geri sayım süresi (60 saniye)
  int _durationSeconds = 60;

  // Nefes döngüsü için metin (Nefes Al, Nefes Ver, Bekle)
  String _breathingText = 'Başlamak İçin Ayarla';

  // YENİ: Duraklatma durumunu kontrol etmek için
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();

    // 1. Nabız/Nefes Animasyonu (0.8'den 1.2 katına)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Bir nefes döngüsü 4 saniye sürsün
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Nabız kontrolcüsü bittiğinde (4 saniye), tersine çalışmaya başlar
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
      _updateBreathingText();
    });

    // 2. Kronometre Animasyonu (Geri sayım)
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _durationSeconds),
    );

    // Kronometre bittiğinde animasyonları durdur
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && _timerController.value == 0.0) {
        _pulseController.stop();
        setState(() {
          _breathingText = 'Tamamlandı!';
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  // --- Metotlar ---

  // GÜNCELLENDİ: Başlat veya Devam Et işlevi
  void _startTimer() {
    setState(() {
      _breathingText = 'Nefes Al';
      _isPaused = false;
    });
    // Kronometreyi başlat (veya kaldığı yerden devam ettir)
    _timerController.reverse(from: _timerController.value == 0.0 ? 1.0 : _timerController.value);
    // Nefes animasyonunu başlat (veya kaldığı yerden devam ettir)
    _pulseController.repeat(reverse: true);
  }

  // YENİ: Duraklat Metodu
  void _pauseTimer() {
    _timerController.stop();
    _pulseController.stop();
    setState(() {
      _breathingText = 'DURAKLATILDI';
      _isPaused = true;
    });
  }


  void _resetTimer() {
    _timerController.stop();
    _pulseController.stop();
    _timerController.value = 0.0;
    setState(() {
      _breathingText = 'Başlamak İçin Ayarla';
      _isPaused = false;
    });
  }

  void _updateBreathingText() {
    // Duraklatılmışsa metni güncelleme
    if (_isPaused) return;

    final status = _pulseController.status;
    if (status == AnimationStatus.forward) {
      // 0.8'den 1.2'ye büyüyor: Nefes Al
      setState(() {
        _breathingText = 'Nefes Al';
      });
    } else if (status == AnimationStatus.reverse) {
      // 1.2'den 0.8'e küçülüyor: Nefes Ver
      setState(() {
        _breathingText = 'Nefes Ver';
      });
    }
  }

  String get _timerString {
    final duration = _timerController.duration! * _timerController.value;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- Arayüz Yapıcılar ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: lightCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Sakinleşmeye mi ihtiyacınız var! Sizler için oluşturduğumuz nefes egzersizi sayfasını deneyin.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    // AnimatedBuilder kullanarak sadece kronometre metnini günceller
    return AnimatedBuilder(
      animation: _timerController,
      builder: (context, child) {
        return Column(
          children: [
            // Büyük Kronometre Metni
            Text(
              _timerString,
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w100,
                color: Theme.of(context).primaryColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            // Nefes Al/Ver Metni
            Text(
              _breathingText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: greyText,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBreathingCircle() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDurationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Süre: ${_durationSeconds ~/ 60} dakika',
          style: TextStyle(color: greyText, fontSize: 16),
        ),
        const SizedBox(width: 15),
        // Süre Azaltma
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          color: Theme.of(context).primaryColor,
          // Kronometre çalışmıyorken veya duraklatılmışken süre değiştirilebilir.
          onPressed: (_timerController.isAnimating || _isPaused)
              ? null
              : () {
            setState(() {
              if (_durationSeconds > 60) _durationSeconds -= 60;
              _timerController.duration = Duration(seconds: _durationSeconds);
            });
          },
        ),
        // Süre Artırma
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: Theme.of(context).primaryColor,
          // Kronometre çalışmıyorken veya duraklatılmışken süre değiştirilebilir.
          onPressed: (_timerController.isAnimating || _isPaused)
              ? null
              : () {
            setState(() {
              _durationSeconds += 60;
              _timerController.duration = Duration(seconds: _durationSeconds);
            });
          },
        ),
      ],
    );
  }

  // GÜNCELLENDİ: Kontrol Butonları
  Widget _buildControls() {
    // 1. Durum Kontrolü
    // - Başlangıç/Sıfırlanmış: _timerController.value == 0.0
    // - Çalışıyor: _timerController.isAnimating == true
    // - Duraklatılmış: _isPaused == true

    Widget primaryButton;
    Widget secondaryButton;

    if (_timerController.value == 0.0) {
      // Durum: Başlangıç/Sıfırlanmış
      primaryButton = ElevatedButton(
        onPressed: _startTimer,
        child: const Text('Başlat', style: TextStyle(fontWeight: FontWeight.bold)),
      );
      secondaryButton = ElevatedButton(
        onPressed: null, // Sıfırlama zaten yapılmış
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade400),
        child: const Text('Sıfırla', style: TextStyle(color: Colors.white)),
      );
    } else if (_timerController.isAnimating) {
      // Durum: Çalışıyor
      primaryButton = ElevatedButton(
        onPressed: _pauseTimer, // YENİ: Duraklat
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
        child: const Text('Duraklat', style: TextStyle(fontWeight: FontWeight.bold)),
      );
      secondaryButton = ElevatedButton(
        onPressed: _resetTimer,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
        child: const Text('Sıfırla', style: TextStyle(color: Colors.white)),
      );
    } else {
      // Durum: Duraklatılmış
      primaryButton = ElevatedButton(
        onPressed: _startTimer, // Devam et
        child: const Text('Devam Et', style: TextStyle(fontWeight: FontWeight.bold)),
      );
      secondaryButton = ElevatedButton(
        onPressed: _resetTimer,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
        child: const Text('Sıfırla', style: TextStyle(color: Colors.white)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [secondaryButton, primaryButton],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(), // Üst Giriş Yazısı

            const SizedBox(height: 30),

            Center(child: _buildBreathingCircle()), // Animasyonlu daire

            const SizedBox(height: 50),

            Center(child: _buildTimerDisplay()), // Kronometre

            const SizedBox(height: 50),

            _buildDurationControls(), // Süre Ayarlama

            _buildControls(), // Başlat/Duraklat/Sıfırla
          ],
        ),
      ),
    );
  }
}