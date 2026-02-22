import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../HomePage/widgets/dark_background.dart';
import 'visa_page.dart';

class VisaFeedbackPage extends StatefulWidget {
  final Map<String, dynamic> feedback;
  final VisaCity city;
  final VoidCallback onRestart;

  const VisaFeedbackPage({super.key, required this.feedback, required this.city, required this.onRestart});

  @override
  State<VisaFeedbackPage> createState() => _VisaFeedbackPageState();
}

class _VisaFeedbackPageState extends State<VisaFeedbackPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final f = widget.feedback;
    final score        = f['overallScore'] as int?   ?? 0;
    final verdict      = f['verdict']     as String? ?? 'Needs Practice';
    final summary      = f['summary']     as String? ?? '';
    final strengths    = List<String>.from(f['strengths']    ?? []);
    final improvements = List<String>.from(f['improvements'] ?? []);
    final tips         = List<String>.from(f['tips']         ?? []);
    final answers      = List<Map>.from(f['answerAnalysis']  ?? []);

    final verdictColor = score >= 75
        ? const Color(0xFF22C55E)
        : score >= 50
            ? const Color(0xFFF59E0B)
            : Colors.redAccent;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text("${widget.city.flag} Результаты", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
      body: Stack(
        children: [
          const DarkTopBackground(),
          Positioned(top: 200, left: 0, right: 0, bottom: 0, child: Container(color: const Color(0xFFF4F5FA))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                children: [
                  // Score
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 130, height: 130,
                              child: CircularProgressIndicator(
                                value: score / 100,
                                strokeWidth: 10,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(verdictColor),
                              ),
                            ),
                            Column(
                              children: [
                                Text('$score', style: GoogleFonts.montserrat(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white)),
                                Text('/100', style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(color: verdictColor, borderRadius: BorderRadius.circular(20)),
                          child: Text(verdict, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                        if (summary.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(summary, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white.withValues(alpha: 0.8), height: 1.5)),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tabs
                  if (answers.isNotEmpty) ...[
                    _buildTabs(),
                    const SizedBox(height: 14),
                  ],

                  if (_tab == 0) ...[
                    if (strengths.isNotEmpty) ...[
                      _card(_bulletSection("✅ Сильные стороны", strengths, const Color(0xFF22C55E))),
                      const SizedBox(height: 14),
                    ],
                    if (improvements.isNotEmpty) ...[
                      _card(_bulletSection("📈 Что улучшить", improvements, const Color(0xFF7C5CFF))),
                      const SizedBox(height: 14),
                    ],
                    if (tips.isNotEmpty) ...[
                      _card(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _title("💡 Конкретные советы"),
                          const SizedBox(height: 12),
                          ...tips.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(color: const Color(0xFF7C5CFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Center(child: Text('${e.key + 1}', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF7C5CFF)))),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(e.value, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF475569), height: 1.4))),
                              ],
                            ),
                          )),
                        ],
                      )),
                    ],
                  ],

                  if (_tab == 1) ...[
                    ...answers.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _card(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF7C5CFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                child: Text('Q${e.key + 1}', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF7C5CFF))),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(e.value['question'] ?? '', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)))),
                            ],
                          ),
                          if (e.value['score'] != null) ...[
                            const SizedBox(height: 8),
                            Text('Оценка: ${e.value['score']}/100', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w900, color: _scoreColor((e.value['score'] as num).toInt()))),
                          ],
                          if (e.value['feedback'] != null) ...[
                            const SizedBox(height: 8),
                            Text(e.value['feedback'], style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF475569), height: 1.4)),
                          ],
                        ],
                      )),
                    )),
                  ],

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity, height: 54,
                    child: ElevatedButton(
                      onPressed: widget.onRestart,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C5CFF), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                      child: Text("Попробовать снова", style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
      child: Row(
        children: [
          _tabBtn("Обзор", 0),
          _tabBtn("По вопросам", 1),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int index) {
    final sel = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: sel ? const Color(0xFF7C5CFF) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
          child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: sel ? Colors.white : const Color(0xFF94A3B8))),
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black.withValues(alpha: 0.04), offset: const Offset(0, 4))]),
    padding: const EdgeInsets.all(18),
    child: child,
  );

  Widget _title(String t) => Text(t, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)));

  Widget _bulletSection(String title, List<String> items, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _title(title),
      const SizedBox(height: 12),
      ...items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5, right: 10), decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
            Expanded(child: Text(item, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF475569), height: 1.4))),
          ],
        ),
      )),
    ],
  );

  Color _scoreColor(int s) => s >= 75 ? const Color(0xFF22C55E) : s >= 50 ? const Color(0xFFF59E0B) : Colors.redAccent;
}