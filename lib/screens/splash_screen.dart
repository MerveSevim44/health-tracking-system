import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math' as math;

/// 🎨 Modern Color Palette - Matching redesigned screens
class AppColors {
  static const deepPurple = Color(0xFF6C63FF);
  static const deepIndigo = Color(0xFF4834DF);
  static const vibrantCyan = Color(0xFF00D4FF);
  static const electricBlue = Color(0xFF0984E3);
  static const darkBg = Color(0xFF0F0F1E);
  static const cardBg = Color(0xFF1A1A2E);
  static const lightText = Color(0xFFFFFFFF);
  static const mutedText = Color(0xFFB8B8D1);
  static const accentPink = Color(0xFFFF6B9D);
  static const accentGreen = Color(0xFF00D9A3);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _progressController;
  late AnimationController _particleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    // Scale animation with bounce
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    // Pulse animation for logo glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Rotate animation for background elements
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    // Particle floating animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    // Progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    // Start animations sequence
    _startAnimations();
    
    // Navigate after delay
    _navigateToNextScreen();
  }
  
  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _progressController.forward();
  }
  
  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    
    if (!mounted) return;
    
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // User is logged in, go to home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // User is not logged in, go to landing page
      Navigator.pushReplacementNamed(context, '/landing');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),
          
          // Floating particles
          _buildFloatingParticles(),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Logo with pulse animation
                _buildAnimatedLogo(),
                
                const SizedBox(height: 50),
                
                // App name with fade
                _buildAppName(),
                
                const SizedBox(height: 12),
                
                // Tagline
                _buildTagline(),
                
                const Spacer(flex: 2),
                
                // Progress indicator
                _buildProgressIndicator(),
                
                const SizedBox(height: 80),
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
        // Base gradient
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
        
        // Animated orb 1
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return Positioned(
              top: 100 + (_particleController.value * 80),
              right: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.deepPurple.withOpacity(0.4),
                      AppColors.deepPurple.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Animated orb 2
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return Positioned(
              bottom: 150 - (_particleController.value * 60),
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.vibrantCyan.withOpacity(0.3),
                      AppColors.vibrantCyan.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Rotating geometric shape
        AnimatedBuilder(
          animation: _rotateController,
          builder: (context, child) {
            return Positioned(
              top: 200,
              left: 60,
              child: Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
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
  
  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final random = math.Random(index);
            final x = random.nextDouble() * MediaQuery.of(context).size.width;
            final yOffset = _particleController.value * 30 * (index % 2 == 0 ? 1 : -1);
            
            return Positioned(
              left: x,
              top: 100 + (index * 80.0) + yOffset,
              child: Container(
                width: 4 + (index % 3) * 2,
                height: 4 + (index % 3) * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index % 2 == 0 
                      ? AppColors.deepPurple.withOpacity(0.3)
                      : AppColors.vibrantCyan.withOpacity(0.3),
                ),
              ),
            );
          }),
        );
      },
    );
  }
  
  Widget _buildAnimatedLogo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 160,
              height: 160,
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
                    color: AppColors.deepPurple.withOpacity(0.5 + _pulseController.value * 0.3),
                    blurRadius: 40 + (_pulseController.value * 20),
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: AppColors.vibrantCyan.withOpacity(0.3 + _pulseController.value * 0.2),
                    blurRadius: 30 + (_pulseController.value * 15),
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.jpg',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.favorite_rounded,
                      size: 80,
                      color: AppColors.lightText,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildAppName() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            AppColors.lightText,
            AppColors.vibrantCyan,
          ],
        ).createShader(bounds),
        child: const Text(
          'MINOA',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
  
  Widget _buildTagline() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
        ),
      ),
      child: const Text(
        'Your Health Companion',
        style: TextStyle(
          fontSize: 16,
          color: AppColors.mutedText,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0),
      child: Column(
        children: [
          // Modern progress bar with gradient
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.cardBg,
                ),
                child: Stack(
                  children: [
                    // Progress fill
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.deepPurple,
                              AppColors.vibrantCyan,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.deepPurple.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Animated shine effect
                    if (_progressAnimation.value > 0.1)
                      Positioned(
                        left: (_progressAnimation.value * MediaQuery.of(context).size.width * 0.7) - 50,
                        child: Container(
                          width: 30,
                          height: 5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.5),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 25),
          
          // Loading text with fade
          FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 0.7).animate(
              CurvedAnimation(
                parent: _progressController,
                curve: const Interval(0.3, 0.8),
              ),
            ),
            child: const Text(
              'LOADING',
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
