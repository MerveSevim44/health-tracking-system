// 📁 lib/screens/register_screen.dart (Basit Metin Eklenmiş Versiyon)

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// 🎨 ANA UYGULAMA RENK PALETİ
const Color primaryOrange = Color(0xFFE49B6E); // Soft Orange
const Color backgroundBeige = Color(0xFFFFF6EC); // Background Beige
const Color darkTextColor = Color(0xFF5B4A3A); // Dark Text/Brown
const Color lightSecondaryTextColor = Color(0xFF7B746E); // Light Secondary Text Color
const Color white = Colors.white;
const Color headerBackgroundColor = Color(0xFFFAE9D7); // Başlık Arka Plan Rengi



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final int _currentPage = 1;
  final int _totalPages = 3;

  // ... (Page Indicator Functions ve diğer metotlar aynı kalır) ...
  Widget _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _totalPages; i++) {
      list.add(_indicator(i == _currentPage));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: list,
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? darkTextColor : lightSecondaryTextColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
  // -----------------------------------------------------------

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    setState(() { _isLoading = true; });
    try {
      await _authService.registerUser(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Redirecting to login page.'), backgroundColor: primaryOrange),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }


  Widget _buildMinimalTextField(
      String label, IconData icon, bool isPassword, TextInputType keyboardType, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        style: const TextStyle(color: darkTextColor),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryOrange),
          filled: true,
          fillColor: white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Colors.transparent, width: 0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: primaryOrange, width: 2.0),
          ),
          labelStyle: const TextStyle(color: lightSecondaryTextColor),
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // HEADER (Unchanged)
  // -----------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const Color headerBackgroundColor = Color(0xFFFAE9D7);

    return Container(
      width: size.width,
      height: size.height * 0.25,
      decoration: BoxDecoration(
        color: headerBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange, // Başlık gölgesi
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Back Button
          Positioned(
            top: 40,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: darkTextColor, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Title Text
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Join MINOA!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: darkTextColor, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Create your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: lightSecondaryTextColor, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBeige,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),

            // Sliding form effect
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🔥 YENİ EKLENDİ: Sade metin
                    const SizedBox(height: 60),
                    Text(
                      'Access AI-driven emotional analysis and personalized health tracking tools.',
                      style: TextStyle(color: Colors.black26, fontSize: 16),
                      //textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),


                    // Input Fields
                    _buildMinimalTextField('Username', Icons.person_outline, false, TextInputType.name, _usernameController),
                    const SizedBox(height: 20),
                    _buildMinimalTextField('Email Address', Icons.email_outlined, false, TextInputType.emailAddress, _emailController),
                    const SizedBox(height: 20),
                    _buildMinimalTextField('Password', Icons.lock_outline, true, TextInputType.visiblePassword, _passwordController),
                    const SizedBox(height: 50),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 8,
                          shadowColor: primaryOrange.withOpacity(0.5),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: white)
                            : const Text('Create Account',
                            style: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Log In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?', style: TextStyle(color: darkTextColor.withOpacity(0.7))),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            'Log In',
                            style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    // Page Indicator
                    const SizedBox(height: 20),
                    _buildPageIndicator(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
