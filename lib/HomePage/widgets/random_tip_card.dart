import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/tipsdata.dart';

class RandomTipCard extends StatefulWidget {
  const RandomTipCard({super.key});

  @override
  State<RandomTipCard> createState() => _RandomTipCardState();
}

class _RandomTipCardState extends State<RandomTipCard> {
  String _lastLangCode = '';
  late Map<String, dynamic> _tip;

  Color _iconColor(IconData icon) {
    if (icon == Icons.lightbulb_rounded)   return const Color(0xFFF59E0B);
    if (icon == Icons.mic_rounded)         return const Color(0xFF7C5CFF);
    if (icon == Icons.description_rounded) return const Color(0xFF3B82F6);
    if (icon == Icons.description_outlined)return const Color(0xFF3B82F6);
    if (icon == Icons.psychology_rounded)  return const Color(0xFF10B981);
    if (icon == Icons.psychology_alt_rounded) return const Color(0xFF10B981);
    if (icon == Icons.trending_up_rounded) return const Color(0xFF06B6D4);
    if (icon == Icons.star_rounded)        return const Color(0xFFF59E0B);
    if (icon == Icons.handshake_rounded)   return const Color(0xFFEC4899);
    if (icon == Icons.timer_rounded)       return const Color(0xFFF97316);
    if (icon == Icons.work_outline_rounded)return const Color(0xFF3B82F6);
    if (icon == Icons.folder_open_rounded) return const Color(0xFF06B6D4);
    return const Color(0xFF7C5CFF);
  }

  void _pickTip(String langCode) {
    final tips = List<Map<String, dynamic>>.from(TipsData.getTips(langCode))
      ..shuffle();
    _tip = tips.first;
    _lastLangCode = langCode;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final langCode = Localizations.localeOf(context).languageCode;
    if (langCode != _lastLangCode) {
      _pickTip(langCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _tip['icon'] as IconData;
    final color = _iconColor(icon);

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
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 22),
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
                    color: const Color(0xFF0F172A),
                  ),
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