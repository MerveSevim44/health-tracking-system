import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dart:ui';

/// 🎨 Fresh Modern Color Palette
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
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  Future<void> _signInUser() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Please fill in all fields', isError: true);
      return;
    }
    
    setState(() { _isLoading = true; });
    
    try {
      await _authService.signInUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        _showMessage('Welcome back!');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // Auth Wrapper'a yönlendir (mood check-in kontrolü için)
          Navigator.pushNamedAndRemoveUntil(context, '/auth-wrapper', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }
  
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Please enter your email address', isError: true);
      return;
    }
    
    setState(() { _isLoading = true; });
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        _showMessage('Password reset link sent to $email');
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }
  
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : AppColors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      ),
    );
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Back button
                      _buildBackButton(),
                      
                      const SizedBox(height: 40),
                      
                      // Welcome text
                      _buildWelcomeSection(),
                      
                      const SizedBox(height: 50),
                      
                      // Login form
                      _buildLoginForm(),
                      
                      const SizedBox(height: 25),
                      
                      // Forgot password
                      _buildForgotPassword(),
                      
                      const SizedBox(height: 35),
                      
                      // Login button
                      _buildLoginButton(),
                      
                      const SizedBox(height: 30),
                      
                      // Divider
                      _buildDivider(),
                      
                      const SizedBox(height: 30),
                      
                      // Sign up link
                      _buildSignUpLink(),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
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
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Positioned(
              top: -100 + (_glowController.value * 50),
              right: -100,
              child: Container(
                width: 300,
                height: 300,
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
          animation: _glowController,
          builder: (context, child) {
            return Positioned(
              bottom: -80 - (_glowController.value * 30),
              left: -100,
              child: Container(
                width: 300,
                height: 300,
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
      ],
    );
  }
  
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.deepPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.lightText,
          size: 20,
        ),
      ),
    );
  }
  
  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated icon
        Container(
          width: 80,
          height: 80,
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
          child: const Icon(
            Icons.login_rounded,
            color: AppColors.lightText,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 30),
        
        const Text(
          'Welcome\nBack!',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
            height: 1.2,
            letterSpacing: -1,
          ),
        ),
        
        const SizedBox(height: 12),
        
        const Text(
          'Sign in to continue your health journey',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email field
        _buildGlassTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        
        const SizedBox(height: 20),
        
        // Password field
        _buildGlassTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.mutedText,
            ),
            onPressed: () {
              setState(() { _obscurePassword = !_obscurePassword; });
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.deepPurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(
              color: AppColors.lightText,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 15,
              ),
              prefixIcon: Icon(icon, color: AppColors.deepPurple, size: 22),
              suffixIcon: suffixIcon,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: AppColors.deepPurple, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : _resetPassword,
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppColors.vibrantCyan,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoginButton() {
    return Container(
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
        onPressed: _isLoading ? null : _signInUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.lightText,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
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
    );
  }
  
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.mutedText.withOpacity(0.2),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.mutedText.withOpacity(0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSignUpLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Don\'t have an account? ',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 15,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/register');
            },
            child: const Text(
              'Sign Up',
              style: TextStyle(
                color: AppColors.vibrantCyan,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
