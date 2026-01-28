import 'package:flutter/material.dart';
import 'package:dayindai/Login%20Page/FirstPage.dart';
import 'package:dayindai/HomePage/HomePage.dart';
import 'package:dayindai/Login Page/RegisterPage.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DayInDai',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Firstpage(),
        '/home': (context) => const HomePage(),
        '/register': (context) => const RegisterPage(),

      },
    );
  }
}
