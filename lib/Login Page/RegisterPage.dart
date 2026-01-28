import 'package:flutter/material.dart';
import 'package:dayindai/Login Page/FirstPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
            child: Column(
              children: [
                SizedBox(
                  height: 20,
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
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Пожалуйста, введите ваше имя";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            filled: true, fillColor: Colors.white),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
