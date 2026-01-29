import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayindai/backend/auth_service.dart';
import 'package:dayindai/AuthGate.dart';
import 'ConfirmEmailPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasDigit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Зарегистрироваться",
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF121423),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color(0xFF121423),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RichText(
                        text: TextSpan(
                            text: "Dayind",
                            style: GoogleFonts.montserrat(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: "AI",
                                style: GoogleFonts.montserrat(
                                    fontSize: 40,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            "Введите ваше имя",
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _nameController,
                          //Name TextFormField
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Пожалуйста, введите ваше имя";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Введите ваше имя",
                            prefixIcon: Icon(LucideIcons.user),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            "Введите вашу фамилию",
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _surnameController,
                          //Surname TextFormField
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Пожалуйста, введите вашу фамилию";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Введите вашу фамилию",
                            prefixIcon: Icon(LucideIcons.user),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            "Введите ваш email",
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          //Email TextFormField
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Пожалуйста, введите ваш email";
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return "Пожалуйста, введите корректный email";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Введите ваш email",
                            prefixIcon: Icon(LucideIcons.mail),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            "Введите ваш пароль",
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          //Password TextFormField
                          controller: _passwordController,
                          obscureText: true,
                          onChanged: (value) {
                            setState(() {
                              hasMinLength = value.length >= 6;
                              hasUppercase = value.contains(RegExp(r'[A-Z]'));
                              hasDigit = value.contains(RegExp(r'\d'));
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Пожалуйста, введите ваш пароль";
                            } else if (!hasMinLength ||
                                !hasUppercase ||
                                !hasDigit) {
                              return "Пароль не соответствует требованиям";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Введите ваш пароль",
                            prefixIcon: Icon(LucideIcons.lock),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        _buildRequirement("Минимум 6 символом", hasMinLength),
                        _buildRequirement(
                            "Минимум одна заглавная буква", hasUppercase),
                        _buildRequirement("Минимум одна цифра", hasDigit),
                        SizedBox(
                          height: 30,
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 250,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      final cred =
                                          await _authService.registerUser(
                                        name: _nameController.text.trim(),
                                        surname: _surnameController.text.trim(),
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      );

                                      // Для отладки: покажем uid и emailVerified
                                      final user = cred.user;
                                      debugPrint(
                                          'Registered user uid=${user?.uid}, emailVerified=${user?.emailVerified}');

                                      // Переходим сразу на страницу подтверждения почты
                                      Navigator.pushReplacementNamed(
                                          context, '/confirmEmail');
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Ошибка регистрации: $e')),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  "Зарегистрироваться",
                                  style: GoogleFonts.inter(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
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
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
