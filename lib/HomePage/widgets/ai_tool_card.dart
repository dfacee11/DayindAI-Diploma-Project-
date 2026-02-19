import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dark_background.dart';

class AiToolCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final String buttonText;
  final String imagePath;
  final VoidCallback onTap;

  const AiToolCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.buttonText,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Positioned.fill(
              child: Container(decoration: BoxDecoration(gradient: gradient))),
          Positioned(
            top: -60,
            right: -50,
            child: BlurBlob(
                size: 200, color: Colors.white.withValues(alpha: 0.22)),
          ),
          Positioned(
            bottom: -8,
            right: -14,
            child: Opacity(
              opacity: 0.98,
              child: Image.asset(imagePath,
                  width: 160, height: 160, fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 130, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.20)),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: GoogleFonts.montserrat(
                              fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
