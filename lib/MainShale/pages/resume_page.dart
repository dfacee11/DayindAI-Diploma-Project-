import 'package:flutter/material.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B1220),
      body: Center(
        child: Text("Resume", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}