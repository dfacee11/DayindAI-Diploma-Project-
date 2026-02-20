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

      if (user == null) throw FirebaseAuthException(code: 'user-null');

      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data['disabled'] == true) {
            await _authService.signOut();
            if (!mounted) return;
            messenger.showSnackBar(const SnackBar(content: Text('Account is blocked.')));
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
        'user-not-found'    => 'User with this email not found',
        'wrong-password'    => 'Wrong password',
        'invalid-email'     => 'Invalid email format',
        'too-many-requests' => 'Too many attempts. Try again later.',
        _                   => e.message ?? 'Sign in error',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [
          Positioned(
            top: -100, left: -80,
            child: _BlurBlob(size: 320, color: const Color(0xFF7C5CFF).withValues(alpha: 0.20)),
          ),
          Positioned(
            top: 200, right: -120,
            child: _BlurBlob(size: 280, color: const Color(0xFF2DD4FF).withValues(alpha: 0.15)),
          ),
          Positioned(
            bottom: -60, left: 40,
            child: _BlurBlob(size: 240, color: const Color(0xFF7C5CFF).withValues(alpha: 0.12)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    _buildLogo(),
                    const SizedBox(height: 10),
                    Text(
                      'Prepare to interview with AI',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 52),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5FA),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                          const SizedBox(height: 4),
                          Text('Sign in to continue', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                          const SizedBox(height: 24),
                          _buildLabel('Email'),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _emailController,
                            hint: 'your@email.com',
                            icon: LucideIcons.mail,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter your email';
                              if (!v.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Password'),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _passwordController,
                            hint: '••••••••',
                            icon: LucideIcons.lock,
                            obscure: _isObscured,
                            suffix: IconButton(
                              onPressed: () => setState(() => _isObscured = !_isObscured),
                              icon: Icon(_isObscured ? LucideIcons.eyeOff : LucideIcons.eye, color: const Color(0xFF94A3B8), size: 18),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter your password';
                              if (v.length < 6) return 'At least 6 characters';
                              return null;
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(context, '/resetPassword'),
                              child: Text('Forgot password?', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF7C5CFF))),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C5CFF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : Text('Sign In', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?", style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                          child: Text('Register', style: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFF7C5CFF), fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // пингвин без фона
        Image.asset(
          'assets/images/penguin.png',
          width: 52,
          height: 52,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            text: 'Dayind',
            style: GoogleFonts.montserrat(fontSize: 38, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            children: [
              TextSpan(
                text: 'AI',
                style: GoogleFonts.montserrat(fontSize: 38, color: const Color(0xFF7C5CFF), fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF7C5CFF), width: 2),
        ),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}