import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroUI extends StatelessWidget {
  final VoidCallback onStart;

  const IntroUI({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(),
          const SizedBox(height: 20),
          Text(
            "Classic Interview",
            style: GoogleFonts.montserrat(
                fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "AI speaks like a real interviewer.\nTranscript is optional.",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.70),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C5CFF),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26)),
            ),
            child: Text(
              "Start Interview",
              style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 210,
      height: 210,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.04)
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Center(
            child: Image.asset("assets/images/aipenguin.png",
                width: 160, height: 160, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
