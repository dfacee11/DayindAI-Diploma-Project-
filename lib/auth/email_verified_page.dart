import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EmailVerifiedPage extends StatelessWidget {
  const EmailVerifiedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [
          Positioned(top: -100, left: -80,   child: _BlurBlob(size: 300, color: const Color(0xFF7C5CFF).withValues(alpha: 0.20))),
          Positioned(top: 200,  right: -100, child: _BlurBlob(size: 260, color: const Color(0xFF2DD4FF).withValues(alpha: 0.15))),
          Positioned(bottom: -60, left: 40,  child: _BlurBlob(size: 220, color: const Color(0xFF22C55E).withValues(alpha: 0.12))),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        boxShadow: [BoxShadow(blurRadius: 30, color: const Color(0xFF22C55E).withValues(alpha: 0.35), offset: const Offset(0, 10))],
                      ),
                      child: const Icon(LucideIcons.checkCircle, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 28),
                    Text('Email Verified!', style: GoogleFonts.montserrat(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(
                      'Your account is ready.\nWelcome to DayindAI!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 40),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFFF4F5FA), borderRadius: BorderRadius.circular(28)),
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity, height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/MainShell'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C5CFF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: Text('Continue', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurBlob({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}