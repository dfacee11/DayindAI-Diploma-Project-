import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallLikeCenter extends StatelessWidget {
  final bool aiIsSpeaking;

  const CallLikeCenter({super.key, required this.aiIsSpeaking});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Center(
              child: Image.asset("assets/images/aipenguin.png",
                  width: 120, height: 120),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            aiIsSpeaking ? "Speaking..." : "Waiting...",
            style: GoogleFonts.montserrat(
                fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap transcript icon if you want to read.",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.70),
            ),
          ),
        ],
      ),
    );
  }
}
