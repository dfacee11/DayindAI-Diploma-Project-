import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LastInterviewCard extends StatelessWidget {
  final VoidCallback onTap;

  const LastInterviewCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final langCode = Localizations.localeOf(context).languageCode;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('interviews')
          .doc('last')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _emptyState(context, langCode);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final score        = data['score']    as int?    ?? 0;
        final verdict      = data['verdict']  as String? ?? '';
        final jobRole      = data['jobRole']  as String? ?? '';
        final level        = data['level']    as String? ?? '';
        final improvements = List<String>.from(data['improvements'] ?? []);
        final date         = data['date'] as Timestamp?;

        final scoreColor = score >= 75
            ? const Color(0xFF22C55E)
            : score >= 50
                ? const Color(0xFFF59E0B)
                : Colors.redAccent;

        final verdictColor = verdict == 'Hire'
            ? const Color(0xFF22C55E)
            : verdict == 'No Hire'
                ? Colors.redAccent
                : const Color(0xFFF59E0B);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF7C5CFF).withValues(alpha: 0.12),
                      ),
                      child: const Icon(Icons.mic_rounded,
                          color: Color(0xFF7C5CFF), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(jobRole,
                              style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A))),
                          Text(level,
                              style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$score/100',
                          style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: scoreColor)),
                    ),
                  ],
                ),

                if (verdict.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: verdictColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(verdict,
                        style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: verdictColor)),
                  ),
                ],

                if (improvements.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(_label('improve', langCode),
                      style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  ...improvements.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6, height: 6,
                          margin: const EdgeInsets.only(top: 5, right: 8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF7C5CFF),
                          ),
                        ),
                        Expanded(
                          child: Text(item,
                              style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                  height: 1.4)),
                        ),
                      ],
                    ),
                  )),
                ],

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (date != null)
                      Text(_formatDate(date.toDate(), langCode),
                          style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8))),
                    Text(_label('practice', langCode),
                        style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF7C5CFF))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState(BuildContext context, String langCode) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              blurRadius: 22,
              offset: const Offset(0, 14),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.12),
              ),
              child: const Icon(Icons.mic_rounded,
                  color: Color(0xFF7C5CFF), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_label('noInterview', langCode),
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A))),
                  Text(_label('startFirst', langCode),
                      style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF7C5CFF), size: 22),
          ],
        ),
      ),
    );
  }

  String _label(String key, String langCode) {
    const map = {
      'improve': {'en': 'What to improve:', 'ru': 'Что улучшить:', 'kk': 'Нені жақсарту керек:'},
      'practice': {'en': 'Practice again →', 'ru': 'Практиковаться снова →', 'kk': 'Қайта жаттығу →'},
      'noInterview': {'en': 'No interviews yet', 'ru': 'Интервью ещё не было', 'kk': 'Сұхбат әлі болған жоқ'},
      'startFirst': {'en': 'Start your first AI interview', 'ru': 'Начните первое AI-интервью', 'kk': 'Алғашқы AI сұхбатын бастаңыз'},
    };
    return map[key]?[langCode] ?? map[key]?['en'] ?? key;
  }

  String _formatDate(DateTime date, String langCode) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (langCode == 'ru') {
      if (diff.inDays == 0) return 'Сегодня';
      if (diff.inDays == 1) return 'Вчера';
      if (diff.inDays < 7)  return '${diff.inDays} дн. назад';
      return '${date.day}.${date.month}.${date.year}';
    } else if (langCode == 'kk') {
      if (diff.inDays == 0) return 'Бүгін';
      if (diff.inDays == 1) return 'Кеше';
      if (diff.inDays < 7)  return '${diff.inDays} күн бұрын';
      return '${date.day}.${date.month}.${date.year}';
    } else {
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7)  return '${diff.inDays} days ago';
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}