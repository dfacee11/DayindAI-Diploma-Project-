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
                SizedBox(height: 120),
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
                SizedBox(height: 60),
                Text("Войти",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 20),
                SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Введите Email",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Email",
                            prefixIcon: Icon(LucideIcons.mail),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text("Введите пароль",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Пароль",
                          prefixIcon: Icon(LucideIcons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: () {}, child: Text("Забыли пароль"))),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Войти",
                      style: TextStyle(fontSize: 22, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
