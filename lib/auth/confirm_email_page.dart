import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ConfirmEmailPage extends StatefulWidget {
  const ConfirmEmailPage({super.key});

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  Timer? _checkTimer;
  Timer? _resendTimer;

  bool _canResend = false;
  int _secondsLeft = 30;
  bool _isSending = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startEmailVerificationCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_checking) return;
      _checking = true;
      try {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.emailVerified) {
          timer.cancel();
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/verified');
        }
      } catch (e) {
        debugPrint('ConfirmEmailPage: reload error: $e');
      } finally {
        _checking = false;
      }
    });
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() { _canResend = false; _secondsLeft = 30; });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not found');
      await user.sendEmailVerification();
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Email sent again')));
      _startResendCooldown();
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

  Future<void> _checkNow() async {
    if (_checking) return;
    _checking = true;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        _checkTimer?.cancel();
        if (!mounted) return;
        navigator.pushReplacementNamed('/verified');
      } else {
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('Email not verified yet')));
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Check error: $e')));
    } finally {
      _checking = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [
          Positioned(top: -100, left: -80,   child: _BlurBlob(size: 300, color: const Color(0xFF7C5CFF).withValues(alpha: 0.20))),
          Positioned(top: 200,  right: -100, child: _BlurBlob(size: 260, color: const Color(0xFF2DD4FF).withValues(alpha: 0.15))),
          Positioned(bottom: -60, left: 40,  child: _BlurBlob(size: 220, color: const Color(0xFF7C5CFF).withValues(alpha: 0.12))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      ),
                      child: const Icon(LucideIcons.mail, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text('Check your email', style: GoogleFonts.montserrat(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(
                      email.isNotEmpty
                          ? 'We sent a confirmation to\n$email\nAfter confirmation you will proceed automatically.'
                          : 'We sent a confirmation email.\nAfter confirmation you will proceed automatically.',
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
                          _canResend
                              ? SizedBox(
                                  width: double.infinity, height: 54,
                                  child: ElevatedButton(
                                    onPressed: _isSending ? null : _resendEmail,
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C5CFF), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                                    child: _isSending
                                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                        : Text('Resend Email', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900)),
                                  ),
                                )
                              : Container(
                                  width: double.infinity, height: 54,
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withValues(alpha: 0.06))),
                                  child: Center(
                                    child: Text('Resend available in $_secondsLeft sec', style: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                                  ),
                                ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity, height: 54,
                            child: ElevatedButton(
                              onPressed: _checkNow,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                              child: Text('Check Now', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        navigator.pushReplacementNamed('/FirstPage');
                      },
                      child: Text('Sign out', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
                    ),
                  ],
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
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}