import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme/app_colors.dart';
import '../widgets/navbar_widget.dart';
import 'package:mobile_app_assignment/view/register_view.dart';
import '../model/user.dart'; //
import '../main.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart'; // ✅ Import AuthService
import 'package:shared_preferences/shared_preferences.dart';
import '../model/global_user.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  final AuthService _authService = AuthService(); // ✅ instance of AuthService
  final UserService us = UserService();

  // 🔑 Login method
  Future<void> _loginWithEmail() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter both email and password.");
      return;
    }

    try {
      final loggedInUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ Set global user
      if (loggedInUser != null) {
        GlobalUser.user = loggedInUser;
        print(
          "GlobalUser updated: UID=${GlobalUser.user!.uid}, Email=${GlobalUser.user!.email}",
        );
      }

      // ✅ Save email/password if Remember Me is checked
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', email);
        await prefs.setString('saved_password', password);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showMessage("Login failed: ${e.message}");
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        GlobalUser.user = user;
        print(
          "GlobalUser updated: UID=${GlobalUser.user!.uid}, Email=${GlobalUser.user!.email}",
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainLayout()),
          (route) => false,
        );
      } else {
        _showMessage("Google login cancelled or failed.");
      }
    } catch (e) {
      _showMessage("Google login failed: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.primaryGreen,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔒 Your original UI — unchanged
            // (keeping everything exactly the same)
            Container(
              width: double.infinity,
              height: size.height * 0.325,
              decoration: const BoxDecoration(color: AppColor.primaryGreen),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 110,
                      backgroundColor: AppColor.primaryGreen,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // White form section (unchanged)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColor.softWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Login to your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColor.darkCharcoal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email field
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: AppColor.slateGray),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password field
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: AppColor.slateGray),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColor.slateGray,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Remember Me + Forgot Password (unchanged)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: AppColor.primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember Me',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.slateGray,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColor.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Login button (only logic added here)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loginWithEmail, // ✅ call our login method
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider + Google login + Sign up (all unchanged)
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(thickness: 1, color: Colors.grey),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "or",
                            style: TextStyle(color: AppColor.slateGray),
                          ),
                        ),
                        Expanded(
                          child: Divider(thickness: 1, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _loginWithGoogle, // ✅ call Google login
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.slateGray,
                          side: BorderSide(color: AppColor.slateGray),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://developers.google.com/identity/images/g-logo.png',
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Login with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColor.slateGray,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterView(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: AppColor.primaryGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
