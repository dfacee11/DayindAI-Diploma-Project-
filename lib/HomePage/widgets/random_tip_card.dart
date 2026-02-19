import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/tipsdata.dart';

class RandomTipCard extends StatefulWidget {
  const RandomTipCard({super.key});

  @override
  State<RandomTipCard> createState() => _RandomTipCardState();
}

class _RandomTipCardState extends State<RandomTipCard> {
  late final Map<String, dynamic> _tip;

  @override
  void initState() {
    super.initState();
    final shuffled = List<Map<String, dynamic>>.from(TipsData.tips)..shuffle();
    _tip = shuffled.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: 0.05)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)],
              ),
            ),
            child:
                Icon(_tip['icon'] as IconData, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tip['title'] as String,
                  style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  _tip['text'] as String,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                    height: 1.25,
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
