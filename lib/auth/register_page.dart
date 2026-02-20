import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:dayindai/backend/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController     = TextEditingController();
  final _surnameController  = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  final _authService        = AuthService();

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasDigit     = false;
  bool _isLoading    = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _authService.registerUser(
        name:     _nameController.text.trim(),
        surname:  _surnameController.text.trim(),
        email:    _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      navigator.pushReplacementNamed('/confirmEmail');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? 'Registration error')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF7C5CFF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Register', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          // фоновые блобы
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
              child: Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildLogo(),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Enter your name'),
                            TextFormField(
                              controller: _nameController,
                              validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name' : null,
                              decoration: _inputDecoration('Enter your name', LucideIcons.user),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Enter your surname'),
                            TextFormField(
                              controller: _surnameController,
                              validator: (v) => (v == null || v.isEmpty) ? 'Please enter your surname' : null,
                              decoration: _inputDecoration('Enter your surname', LucideIcons.user),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Enter your email'),
                            TextFormField(
                              controller: _emailController,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please enter your email';
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Please enter a valid email';
                                return null;
                              },
                              decoration: _inputDecoration('Enter your email', LucideIcons.mail),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Enter your password'),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              onChanged: (v) => setState(() {
                                _hasMinLength = v.length >= 6;
                                _hasUppercase = v.contains(RegExp(r'[A-Z]'));
                                _hasDigit     = v.contains(RegExp(r'\d'));
                              }),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please enter your password';
                                if (!_hasMinLength || !_hasUppercase || !_hasDigit) return 'Password does not meet requirements';
                                return null;
                              },
                              decoration: _inputDecoration('Enter your password', LucideIcons.lock),
                            ),
                            const SizedBox(height: 8),
                            _buildRequirement('Minimum 6 characters',        _hasMinLength),
                            _buildRequirement('Minimum one uppercase letter', _hasUppercase),
                            _buildRequirement('Minimum one digit',            _hasDigit),
                            const SizedBox(height: 30),
                            _buildRegisterButton(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/images/penguin.png', width: 52, height: 52, fit: BoxFit.contain),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            text: 'Dayind',
            style: GoogleFonts.montserrat(fontSize: 42, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            children: [
              TextSpan(
                text: 'AI',
                style: GoogleFonts.montserrat(fontSize: 42, color: const Color(0xFF7C5CFF), fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 5),
      child: Text(text, style: GoogleFonts.inter(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildRegisterButton() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C5CFF),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: _isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text('Register', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? LucideIcons.checkCircle : LucideIcons.xCircle,
          size: 16,
          color: isValid ? Colors.green : Colors.white54,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            color: isValid ? Colors.green : Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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