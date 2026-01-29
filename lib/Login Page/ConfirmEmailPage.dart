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

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
    _startResendCooldown();
  }

  /// Проверяем каждые 3 секунды, подтверждён ли email
  void _startEmailVerificationCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      debugPrint(
          'ConfirmEmailPage: after reload user=${user?.uid}, emailVerified=${user?.emailVerified}');
    });
  }

  /// Таймер ожидания перед повторной отправкой письма
  void _startResendCooldown() {
    _resendTimer?.cancel();

    setState(() {
      _canResend = false;
      _secondsLeft = 30;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          _canResend = true;
        });
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Письмо отправлено ещё раз')),
      );

      _startResendCooldown();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Ошибка отправки письма')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Проверьте почту',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 10),
              const Text(
                'Мы отправили письмо для подтверждения email.\n'
                'После подтверждения вы перейдёте дальше автоматически.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              _canResend
                  ? ElevatedButton(
                      onPressed: _isSending ? null : _resendEmail,
                      child: const Text('Отправить письмо ещё раз'),
                    )
                  : Text(
                      'Повторная отправка через $_secondsLeft сек',
                      style: const TextStyle(color: Colors.white70),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
