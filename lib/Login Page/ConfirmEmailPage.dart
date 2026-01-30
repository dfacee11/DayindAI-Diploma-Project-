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

  /// Проверяем каждые 3 секунды, подтверждён ли email.
  /// Если подтверждён — переходим ��а /verified.
  void _startEmailVerificationCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // защита от одновременных проверок
      if (_checking) return;
      _checking = true;
      try {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        debugPrint(
            'ConfirmEmailPage: after reload user=${user?.uid}, email=${user?.email}, emailVerified=${user?.emailVerified}');
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
        if (!mounted) return;
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Пользователь не найден');

      await user.sendEmailVerification();

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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  /// Ручная проверка статуса (кнопка "Проверить сейчас")
  Future<void> _checkNow() async {
    if (_checking) return;
    _checking = true; // блокируем параллельные проверки
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      debugPrint(
          'ConfirmEmailPage manual check: user=${user?.uid}, emailVerified=${user?.emailVerified}');
      if (user != null && user.emailVerified) {
        // Остановим периодическую проверку и перейдём на экран подтверждения
        _checkTimer?.cancel();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/verified');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ещё не подтверждён')),
        );
      }
    } catch (e) {
      debugPrint('ConfirmEmailPage manual check error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при проверке: $e')),
      );
    } finally {
      _checking = false;
      if (mounted) setState(() {}); // обновим UI, если нужно
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
              const Text(
                'Проверьте почту',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 10),
              Text(
                email.isNotEmpty
                    ? 'Мы отправили письмо на $email для подтверждения.\nПосле подтверждения вы перейдёте дальше автоматически.'
                    : 'Мы отправили письмо для подтверждения email.\nПосле подтверждения вы перейдёте дальше автоматически.',
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Отправить письмо ещё раз'),
                    )
                  : Text(
                      'Повторная отправка через $_secondsLeft сек',
                      style: const TextStyle(color: Colors.white70),
                    ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _checkNow,
                child: const Text('Проверить сейчас'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  // Опционально: позволяем выйти из аккаунта, если пользователь хочет
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/FirstPage');
                },
                child: const Text(
                  'Выйти',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}