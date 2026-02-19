import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmReg extends StatelessWidget {
  const ConfirmReg({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Подтверждение регистрации',
          style: GoogleFonts.inter(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF121423),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF121423),
    );
  }
}
