import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroUI extends StatefulWidget {
  final void Function(String jobRole) onStart;

  const IntroUI({super.key, required this.onStart});

  @override
  State<IntroUI> createState() => _IntroUIState();
}

class _IntroUIState extends State<IntroUI> {
  final _roleController = TextEditingController(text: 'Software Engineer');

  final List<String> _presets = [
    'Software Engineer',
    'Product Manager',
    'Data Scientist',
    'UX Designer',
    'Marketing Manager',
  ];

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(),
            const SizedBox(height: 20),
            Text(
              "AI Interview",
              style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              "Real AI interviewer with voice.\nGet feedback after 7 questions.",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.70), height: 1.4),
            ),
            const SizedBox(height: 28),

            // Job role input
            Container(
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.15))),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _roleController,
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Job role...',
                  hintStyle: GoogleFonts.montserrat(color: Colors.white.withValues(alpha: 0.4)),
                  prefixIcon: Icon(Icons.work_outline_rounded, color: Colors.white.withValues(alpha: 0.6), size: 20),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Presets
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _presets.map((role) => GestureDetector(
                onTap: () => setState(() => _roleController.text = role),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Text(role, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.85))),
                ),
              )).toList(),
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: () {
                final role = _roleController.text.trim();
                if (role.isEmpty) return;
                widget.onStart(role);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFF),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text("Start Interview", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0.04)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Center(
            child: Image.asset("assets/images/aipenguin.png", width: 140, height: 140, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}