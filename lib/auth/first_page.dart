import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dayindai/backend/auth_service.dart';
import 'register_page.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _firestore = FirebaseFirestore.instance;

  bool _isObscured = true;
  bool _isLoading = false;

  static const _bg = Color(0xFF121423);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final cred = await _authService.signIn(email: email, password: password);
      final user = cred.user;

      if (user == null) {
        throw FirebaseAuthException(code: 'user-null', message: 'User not found after sign in');
      }

      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data['disabled'] == true) {
            await _authService.signOut();
            if (!mounted) return;
            messenger.showSnackBar(const SnackBar(content: Text('Account is blocked. Contact administrator.')));
            return;
          }
        }
      } catch (e) {
        debugPrint('FirstPage: firestore check error: $e');
      }

      await user.reload();
      final freshUser = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (freshUser != null && !freshUser.emailVerified) {
        navigator.pushReplacementNamed('/confirmEmail');
        return;
      }

      navigator.pushNamedAndRemoveUntil('/MainShell', (route) => false);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'user-not-found'  => 'User with this email not found',
        'wrong-password'  => 'Wrong password',
        'invalid-email'   => 'Invalid email format',
        'too-many-requests' => 'Too many attempts. Try again later.',
        _ => e.message ?? 'Sign in error',
      };
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: GoogleFonts.inter(),
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      helperText: ' ',
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(width: 3, color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 80),
                _buildLogo(),
                const SizedBox(height: 8),
                Text(
                  'Prepare to interview with AI',
                  style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 45),
                Text('Login', style: GoogleFonts.inter(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Enter your email'),
                      TextFormField(
                        controller: _emailController,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter your email';
                          if (!v.contains('@')) return 'Please enter a valid email';
                          return null;
                        },
                        decoration: _inputDecoration('Email', LucideIcons.mail),
                      ),
                      _buildLabel('Enter your password'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter your password';
                          if (v.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                        decoration: _inputDecoration(
                          'Password',
                          LucideIcons.lock,
                          suffix: IconButton(
                            onPressed: () => setState(() => _isObscured = !_isObscured),
                            icon: Icon(_isObscured ? LucideIcons.eyeOff : LucideIcons.eye),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/resetPassword'),
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(fontSize: 13, color: Colors.blue.withValues(alpha: 0.8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Login', style: GoogleFonts.inter(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: GoogleFonts.inter(fontSize: 16, color: Colors.white)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                      child: Text('Register', style: GoogleFonts.inter(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return RichText(
      text: TextSpan(
        text: 'Dayind',
        style: GoogleFonts.montserrat(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: 'AI',
            style: GoogleFonts.montserrat(fontSize: 50, color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4, bottom: 5),
      child: Text(text, style: GoogleFonts.inter(fontSize: 16, color: Colors.white)),
    );
  }
}