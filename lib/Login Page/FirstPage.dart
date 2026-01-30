import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayindai/backend/auth_service.dart';
import 'RegisterPage.dart';

class Firstpage extends StatefulWidget {
  const Firstpage({super.key});

  @override
  State<Firstpage> createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

    try {
      final cred = await _authService.signIn(email: email, password: password);
      final user = cred.user;

      if (user == null) {
        throw FirebaseAuthException(
            code: 'user-null', message: 'Пользователь не найден после входа');
      }

      // Опциональная проверка профиля в Firestore (не прерывает вход)
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          debugPrint('FirstPage: user profile not found in firestore uid=${user.uid}');
          // При необходимости можно создать профиль здесь
        } else {
          final data = doc.data();
          if (data != null && data['disabled'] == true) {
            // Если хотите блокировать вход: разлогиньте и покажите сообщение
            await _authService.signOut();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Учётная запись заблокирована. Обратитесь к администратору.')),
            );
            return;
          }
        }
      } catch (e) {
        debugPrint('FirstPage: firestore check error: $e');
        // не критично — продолжаем
      }

      // Обновляем состояние пользователя и проверяем emailVerified
      await user.reload();
      final freshUser = FirebaseAuth.instance.currentUser;

      if (freshUser != null && !freshUser.emailVerified) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/confirmEmail');
        return;
      }

      // Всё хорошо — переходим в приложение
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Пользователь с таким email не найден';
          break;
        case 'wrong-password':
          message = 'Неверный пароль';
          break;
        case 'invalid-email':
          message = 'Неверный формат email';
          break;
        case 'too-many-requests':
          message = 'Слишком много попыток. Попробуйте позже.';
          break;
        default:
          message = e.message ?? 'Ошибка при входе';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121423),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 80),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: RichText(
                      text: TextSpan(
                          text: "Dayind",
                          style: GoogleFonts.montserrat(
                              fontSize: 50,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: "AI",
                              style: GoogleFonts.montserrat(
                                  fontSize: 50,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                Text("Подготовка к интервью с помощью AI",
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 45),
                Text("Войти",
                    style: GoogleFonts.inter(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text("Введите Email",
                              style: GoogleFonts.inter(
                                  fontSize: 16, color: Colors.white)),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          //TextFormField for email input
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Пожалуйста введите Email";
                            }
                            if (!value.contains("@")) {
                              return "Пожалуйста введите корректный Email";
                            }
                            return null;
                          },
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Email",
                            hintStyle: GoogleFonts.inter(),
                            prefixIcon: const Icon(LucideIcons.mail),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                width: 3,
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Colors.red,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            helperText: ' ',
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text("Введите пароль",
                            style: GoogleFonts.inter(
                                fontSize: 16, color: Colors.white)),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        //TextFormField for password input
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Пожалуйста введите пароль";
                          }
                          if (value.length < 6) {
                            return "Пароль должен быть не менее 6 символов";
                          }
                          return null;
                        },
                        controller: _passwordController,
                        obscureText: _isObscured,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Пароль",
                          hintStyle: GoogleFonts.inter(),
                          prefixIcon: const Icon(LucideIcons.lock),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(
                                  () {
                                    _isObscured = !_isObscured;
                                  },
                                );
                              },
                              icon: Icon(_isObscured
                                  ? LucideIcons.eyeOff
                                  : LucideIcons.eye)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              width: 3,
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          helperText: " ",
                          helperStyle: const TextStyle(height: 0.2),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            // Убедитесь, что в main.dart добавлен маршрут '/reset'
                            Navigator.pushNamed(context, '/resetPassword');
                          },
                          child: Text(
                            "Забыли пароль",
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.withOpacity(0.8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  //Buttton for login
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Войти",
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Нет аккаунта?",
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w400)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage()),
                        );
                      },
                      child: Text(
                        "Зарегистрироваться",
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}