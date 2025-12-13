import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🎨 Fresh Modern Color Palette - Complete Redesign
class AppColors {
  // Deep gradient colors
  static const deepPurple = Color(0xFF6C63FF);
  static const deepIndigo = Color(0xFF4834DF);
  static const vibrantCyan = Color(0xFF00D4FF);
  static const electricBlue = Color(0xFF0984E3);
  
  // Neutral tones
  static const darkBg = Color(0xFF0F0F1E);
  static const cardBg = Color(0xFF1A1A2E);
  static const lightText = Color(0xFFFFFFFF);
  static const mutedText = Color(0xFFB8B8D1);
  
  // Accent colors
  static const accentPink = Color(0xFFFF6B9D);
  static const accentOrange = Color(0xFFFF9F43);
  static const accentGreen = Color(0xFF00D9A3);
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  
  int _currentPage = 0;
  
  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Your Health,\nReimagined',
      'subtitle': 'Track, analyze, and improve your wellbeing with AI-powered insights',
      'icon': Icons.auto_awesome,
    },
    {
      'title': 'Smart\nTracking',
      'subtitle': 'Monitor mood, hydration, medications, and more in one beautiful app',
      'icon': Icons.insights,
    },
    {
      'title': 'AI-Powered\nInsights',
      'subtitle': 'Get personalized recommendations based on your health patterns',
      'icon': Icons.psychology,
    },
    {
      'title': 'Stay\nMotivated',
      'subtitle': 'Beautiful visualizations and achievements keep you engaged',
      'icon': Icons.emoji_events,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top navigation bar
                _buildTopBar(),
                
                // Page view with sections
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _sections.length,
                    itemBuilder: (context, index) {
                      return _buildSection(index);
                    },
                  ),
                ),
                
                // Page indicators
                _buildPageIndicators(),
                
                const SizedBox(height: 20),
                
                // CTA Buttons
                _buildCTAButtons(),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkBg,
                AppColors.deepIndigo.withOpacity(0.3),
                AppColors.darkBg,
              ],
            ),
          ),
        ),
        
        // Floating orbs
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Positioned(
              top: 100 + (_floatController.value * 50),
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.deepPurple.withOpacity(0.3),
                      AppColors.deepPurple.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Positioned(
              bottom: 150 - (_floatController.value * 30),
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.vibrantCyan.withOpacity(0.2),
                      AppColors.vibrantCyan.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Rotating shapes
        AnimatedBuilder(
          animation: _rotateController,
          builder: (context, child) {
            return Positioned(
              top: 300,
              left: 50,
              child: Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentPink.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.deepPurple, AppColors.vibrantCyan],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepPurple.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.lightText,
              size: 24,
            ),
          ),
          
          // App name
          const Text(
            'MINOA',
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          
          // Skip button
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(int index) {
    final section = _sections[index];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.deepPurple,
                        AppColors.vibrantCyan,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepPurple.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    section['icon'] as IconData,
                    size: 70,
                    color: AppColors.lightText,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 60),
          
          // Title
          Text(
            section['title'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.lightText,
              height: 1.2,
              letterSpacing: -1,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Subtitle
          Text(
            section['subtitle'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.mutedText,
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Features grid (only for certain pages)
          if (index == 1) _buildFeaturesGrid(),
        ],
      ),
    );
  }
  
  Widget _buildFeaturesGrid() {
    final features = [
      {'icon': Icons.mood, 'label': 'Mood', 'color': AppColors.accentPink},
      {'icon': Icons.water_drop, 'label': 'Hydration', 'color': AppColors.vibrantCyan},
      {'icon': Icons.medication, 'label': 'Meds', 'color': AppColors.accentOrange},
      {'icon': Icons.insights, 'label': 'Insights', 'color': AppColors.accentGreen},
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate item width based on available space
          final itemWidth = (constraints.maxWidth - 45) / 4; // 4 items with 15px spacing
          
          return Wrap(
            spacing: 15,
            runSpacing: 15,
            alignment: WrapAlignment.center,
            children: features.map((feature) {
              return Container(
                width: itemWidth.clamp(65.0, 85.0), // Min 65, Max 85
                height: itemWidth.clamp(65.0, 85.0),
                decoration: BoxDecoration(
                  color: (feature['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (feature['color'] as Color).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: feature['color'] as Color,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['label'] as String,
                      style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
  
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_sections.length, (index) {
        final isActive = index == _currentPage;
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 40 : 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                      colors: [AppColors.deepPurple, AppColors.vibrantCyan],
                    )
                  : null,
              color: isActive ? null : AppColors.mutedText.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildCTAButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Get Started Button
          Container(
            width: double.infinity,
            height: 65,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.deepPurple, AppColors.vibrantCyan],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepPurple.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Started Free',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.lightText),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Login Button
          Container(
            width: double.infinity,
            height: 65,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.deepPurple.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'I Already Have an Account',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
