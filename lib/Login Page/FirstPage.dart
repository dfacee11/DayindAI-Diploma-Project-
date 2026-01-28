import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121423),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 80),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(5),
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
                SizedBox(height: 0),
                Text("Подготовка к интервью с помощью AI",
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: 45),
                Text("Войти",
                    style: GoogleFonts.inter(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Введите Email",
                              style: GoogleFonts.inter(
                                  fontSize: 16, color: Colors.white)),
                        ),
                        SizedBox(height: 5),
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
                            prefixIcon: Icon(LucideIcons.mail),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                width: 3,
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            helperText: ' ',
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text("Введите пароль",
                            style: GoogleFonts.inter(
                                fontSize: 16, color: Colors.white)),
                      ),
                      SizedBox(height: 5),
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
                          prefixIcon: Icon(LucideIcons.lock),
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
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          helperText: " ",
                          helperStyle: TextStyle(height: 0.2),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {},
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
                SizedBox(height: 20),
                ElevatedButton(
                  //Buttton for login
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text("Войти",
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 20),
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
                        Navigator.pushNamed(context, '/register');
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
                SizedBox(
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
