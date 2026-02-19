import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    setState(() {
      _canResend = false;
      _secondsLeft = 30;
    });
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
      backgroundColor: const Color(0xFF121423),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text('Check your email', style: TextStyle(color: Colors.white, fontSize: 22)),
              const SizedBox(height: 10),
              Text(
                email.isNotEmpty
                    ? 'We sent a letter to $email.\nAfter confirmation you will proceed automatically.'
                    : 'We sent a confirmation email.\nAfter confirmation you will proceed automatically.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              _canResend
                  ? ElevatedButton(
                      onPressed: _isSending ? null : _resendEmail,
                      child: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Resend email'),
                    )
                  : Text(
                      'Resend available in $_secondsLeft sec',
                      style: const TextStyle(color: Colors.white70),
                    ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _checkNow,
                child: const Text('Check now'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  navigator.pushReplacementNamed('/FirstPage');
                },
                child: const Text('Sign out', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}