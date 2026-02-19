import 'dart:ui';
import 'package:flutter/material.dart';

class DarkTopBackground extends StatelessWidget {
  const DarkTopBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1220), Color(0xFF121A2B), Color(0xFF1A2236)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -90,
            child: BlurBlob(
                size: 300,
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.22)),
          ),
          Positioned(
            top: 120,
            right: -130,
            child: BlurBlob(
                size: 340,
                color: const Color(0xFF2DD4FF).withValues(alpha: 0.18)),
          ),
        ],
      ),
    );
  }
}

class BlurBlob extends StatelessWidget {
  final double size;
  final Color color;

  const BlurBlob({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
