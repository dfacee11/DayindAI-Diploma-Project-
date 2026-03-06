import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/tipsdata.dart';

class RandomTipCard extends StatefulWidget {
  const RandomTipCard({super.key});

  @override
  State<RandomTipCard> createState() => _RandomTipCardState();
}

class _RandomTipCardState extends State<RandomTipCard> {
  String _lastLangCode = '';
  late Map<String, dynamic> _tip;
  int _streak = 0;
  bool _claimedToday = false;

  
  void _pickTip(String langCode) {
    final tips = List<Map<String, dynamic>>.from(TipsData.getTips(langCode));
    final dayIndex = DateTime.now().difference(DateTime(2025)).inDays % tips.length;
    _tip = tips[dayIndex];
    _lastLangCode = langCode;
  }

  
  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final lastDay = prefs.getString('tip_last_day') ?? '';
    final streak = prefs.getInt('tip_streak') ?? 0;

    if (lastDay == today) {
      
      setState(() {
        _streak = streak;
        _claimedToday = true;
      });
    } else {
      
      final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
      final newStreak = (lastDay == yesterday) ? streak + 1 : 1;

      await prefs.setString('tip_last_day', today);
      await prefs.setInt('tip_streak', newStreak);

      setState(() {
        _streak = newStreak;
        _claimedToday = true;
      });
    }
  }

  String _todayKey() => _dayKey(DateTime.now());
  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Color _iconColor(IconData icon) {
    if (icon == Icons.lightbulb_rounded)      return const Color(0xFFF59E0B);
    if (icon == Icons.mic_rounded)            return const Color(0xFF7C5CFF);
    if (icon == Icons.description_rounded)    return const Color(0xFF3B82F6);
    if (icon == Icons.description_outlined)   return const Color(0xFF3B82F6);
    if (icon == Icons.psychology_rounded)     return const Color(0xFF10B981);
    if (icon == Icons.psychology_alt_rounded) return const Color(0xFF10B981);
    if (icon == Icons.trending_up_rounded)    return const Color(0xFF06B6D4);
    if (icon == Icons.star_rounded)           return const Color(0xFFF59E0B);
    if (icon == Icons.handshake_rounded)      return const Color(0xFFEC4899);
    if (icon == Icons.timer_rounded)          return const Color(0xFFF97316);
    if (icon == Icons.work_outline_rounded)   return const Color(0xFF3B82F6);
    if (icon == Icons.folder_open_rounded)    return const Color(0xFF06B6D4);
    return const Color(0xFF7C5CFF);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final langCode = Localizations.localeOf(context).languageCode;
    if (langCode != _lastLangCode) {
      _pickTip(langCode);
      _loadStreak();
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _tip['icon'] as IconData;
    final color = _iconColor(icon);
    final langCode = Localizations.localeOf(context).languageCode;

    final streakLabel = switch (langCode) {
      'ru' => 'день подряд',
      'kk' => 'күн қатарынан',
      _ => 'day streak',
    };
    final tipOfDayLabel = switch (langCode) {
      'ru' => 'Совет дня',
      'kk' => 'Күнің кеңесі',
      _ => 'Tip of the day',
    };

    return Container(
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
      child: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C5CFF), Color(0xFF9F7AFF)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '$_streak $streakLabel',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tipOfDayLabel,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.all(16),
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
          ),
        ],
      ),
    );
  }
}