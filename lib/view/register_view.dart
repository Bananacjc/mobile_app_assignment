import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile_app_assignment/view/login_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart'; // ✅ bcrypt for hashing
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/theme/app_colors.dart';
import '../widgets/navbar_widget.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      final authService = AuthService();

      // ✅ Create user in Firebase Auth
      final user = await authService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (user != null) {
        // ✅ Update FirebaseAuth profile with full name
        final fullName =
            "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";
        await user.updateDisplayName(fullName);
        await user.reload(); // reload so it reflects immediately

        // refresh user reference
        final updatedUser = FirebaseAuth.instance.currentUser;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Account created: ${updatedUser?.displayName}")),
        );

        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";
      if (e.code == 'weak-password') message = "Password is too weak";
      if (e.code == 'email-already-in-use') message = "Email is already registered";
      if (e.code == 'invalid-email') message = "Invalid email address";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.primaryGreen,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green header with logo
            Container(
              width: double.infinity,
              height: size.height * 0.325,
              decoration: const BoxDecoration(
                color: AppColor.primaryGreen,
              ),
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

            // ✅ Form content (unchanged UI)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.softWhite,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      const Center(
                        child: Text(
                          'Sign up an account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColor.darkCharcoal,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ✅ First Name + Last Name Row (UI same as yours)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'First Name',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.darkCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _firstNameController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter first name',
                                    hintStyle: const TextStyle(
                                      color: AppColor.slateGray,
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: AppColor.softWhite,
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
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Last Name',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.darkCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _lastNameController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter last name',
                                    hintStyle: const TextStyle(
                                      color: AppColor.slateGray,
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: AppColor.softWhite,
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
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ✅ Email (same as yours)
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: const TextStyle(
                            color: AppColor.slateGray,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppColor.softWhite,
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

                      const SizedBox(height: 24),

                      // ✅ Password + Confirm Password (UI same as yours)
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(
                            color: AppColor.slateGray,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppColor.softWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColor.slateGray,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Confirm your password',
                          hintStyle: const TextStyle(
                            color: AppColor.slateGray,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppColor.softWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColor.slateGray,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ✅ Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _register, // ✅ Now saves to Firestore+bcrypt
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginView()),
                            );
                          },
                          child: const Text(
                            'Back to login',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColor.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}