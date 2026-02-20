import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    final email = _emailController.text.trim();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Email Sent', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900)),
          content: Text(
            'Password recovery email sent to $email.\nCheck your inbox and follow the instructions.',
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                navigator.pushReplacementNamed('/FirstPage');
              },
              child: Text('OK', style: GoogleFonts.montserrat(color: const Color(0xFF7C5CFF), fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? 'Error sending email')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Password Recovery', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          Positioned(top: -100, left: -80,  child: _BlurBlob(size: 300, color: const Color(0xFF7C5CFF).withValues(alpha: 0.20))),
          Positioned(top: 150,  right: -100, child: _BlurBlob(size: 260, color: const Color(0xFF2DD4FF).withValues(alpha: 0.15))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(LucideIcons.unlock, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 20),
                      Text('Password Recovery', style: GoogleFonts.montserrat(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Text(
                        'Enter the email associated with your account.\nWe will send a link to reset your password.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 32),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: const Color(0xFFF4F5FA), borderRadius: BorderRadius.circular(28)),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter your email';
                                if (!v.contains('@')) return 'Invalid email';
                                return null;
                              },
                              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                hintText: 'your@email.com',
                                hintStyle: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFF94A3B8)),
                                prefixIcon: const Icon(LucideIcons.mail, size: 18, color: Color(0xFF94A3B8)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF7C5CFF), width: 2)),
                                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isSending ? null : _sendResetEmail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C5CFF),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                                child: _isSending
                                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : Text('Send Recovery Email', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/FirstPage'),
                        child: Text('Return to Login', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
                      ),
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
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }
}