import 'dart:ui';
import 'package:flutter/material.dart';

class CenterAiButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;

  const CenterAiButton({super.key, required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.95),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              offset: const Offset(0, 16),
              color: Colors.black.withValues(alpha: 0.22),
            ),
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: const Color(0xFF7C5CFF).withValues(alpha: 0.20),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)],
                ),
              ),
              child: Center(
                child: Image.asset(
                  "assets/images/penguin.png",
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}