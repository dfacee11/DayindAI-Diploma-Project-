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

  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasDigit     = false;
  bool _isLoading   = false;

  static const _bg = Color(0xFF121423);

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.blue),
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
      setState(() => _isLoading = false);
      navigator.pushReplacementNamed('/confirmEmail');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? 'Registration error')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text('Register', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: _bg,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
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
                            hasMinLength = v.length >= 6;
                            hasUppercase = v.contains(RegExp(r'[A-Z]'));
                            hasDigit     = v.contains(RegExp(r'\d'));
                          }),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter your password';
                            if (!hasMinLength || !hasUppercase || !hasDigit) return 'Password does not meet requirements';
                            return null;
                          },
                          decoration: _inputDecoration('Enter your password', LucideIcons.lock),
                        ),
                        const SizedBox(height: 8),
                        _buildRequirement('Minimum 6 characters',        hasMinLength),
                        _buildRequirement('Minimum one uppercase letter', hasUppercase),
                        _buildRequirement('Minimum one digit',            hasDigit),
                        const SizedBox(height: 30),
                        _buildRegisterButton(),
                      ],
                    ),
                  ),
                ],
              ),
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
        style: GoogleFonts.montserrat(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: 'AI',
            style: GoogleFonts.montserrat(fontSize: 40, color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 5),
      child: Text(text, style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
    );
  }

  Widget _buildRegisterButton() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 250,
        height: 60,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _register,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) return Colors.grey;
              if (states.contains(WidgetState.pressed))  return Colors.red.shade700;
              return Colors.red;
            }),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Register', style: GoogleFonts.inter(color: Colors.white, fontSize: 18)),
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
          color: isValid ? Colors.green : Colors.white,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            color: isValid ? Colors.green : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}