import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ConfirmReg extends StatelessWidget {
  const ConfirmReg({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Registration', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          Positioned(top: -100, left: -80,   child: _BlurBlob(size: 300, color: const Color(0xFF7C5CFF).withValues(alpha: 0.20))),
          Positioned(top: 200,  right: -100, child: _BlurBlob(size: 260, color: const Color(0xFF2DD4FF).withValues(alpha: 0.15))),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      ),
                      child: const Icon(LucideIcons.userCheck, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text('Registration Confirmed', style: GoogleFonts.montserrat(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(
                      'Your registration is complete.\nProceed to sign in.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFFF4F5FA), borderRadius: BorderRadius.circular(28)),
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity, height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/FirstPage'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C5CFF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: Text('Go to Sign In', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900)),
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