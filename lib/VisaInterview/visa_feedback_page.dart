import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../HomePage/widgets/dark_background.dart';
import 'models/visa_city.dart';

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
    final verdict   = f['verdict']       as String? ?? 'Одобрено';
    final summary   = f['summary']       as String? ?? '';
    final redFlags  = List<String>.from(f['redFlags']    ?? []);
    final strengths = List<String>.from(f['strengths']   ?? []);
    final tips      = List<String>.from(f['tips']        ?? []);
    final answers   = List<Map>.from(f['answerAnalysis'] ?? []);

    final isApproved   = verdict == 'Одобрено';
    final verdictColor = isApproved ? const Color(0xFF22C55E) : Colors.redAccent;
    final verdictIcon  = isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final verdictLabel = isApproved ? '✅ VISA APPROVED' : '❌ VISA REJECTED';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text("Результаты",
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
      body: Stack(
        children: [
          const DarkTopBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      color: verdictColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: verdictColor.withValues(alpha: 0.5), width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(verdictIcon, color: verdictColor, size: 64),
                        const SizedBox(height: 14),
                        Text(verdictLabel,
                            style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: verdictColor)),
                        if (summary.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(summary,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white.withValues(alpha: 0.8), height: 1.5)),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (!isApproved && redFlags.isNotEmpty) ...[
                    _card(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title("🚨 Причины отказа"),
                        const SizedBox(height: 12),
                        ...redFlags.map((flag) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 10),
                              Expanded(child: Text(flag,
                                  style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600,
                                      color: Colors.redAccent, height: 1.4))),
                            ],
                          ),
                        )),
                      ],
                    )),
                    const SizedBox(height: 14),
                  ],

                  if (answers.isNotEmpty) ...[
                    _buildTabs(),
                    const SizedBox(height: 14),
                  ],

                  if (_tab == 0) ...[
                    if (strengths.isNotEmpty) ...[
                      _card(_bulletSection("✅ Что хорошо", strengths, const Color(0xFF22C55E))),
                      const SizedBox(height: 14),
                    ],
                    if (tips.isNotEmpty) ...[
                      _card(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _title("💡 Советы на следующий раз"),
                          const SizedBox(height: 12),
                          ...tips.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7C5CFF).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(child: Text('${e.key + 1}',
                                      style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF7C5CFF)))),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(e.value,
                                    style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(alpha: 0.75), height: 1.4))),
                              ],
                            ),
                          )),
                        ],
                      )),
                    ],
                  ],

                  if (_tab == 1)
                    ...answers.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _card(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _answerVerdictColor(e.value['verdict']).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('Q${e.key + 1}',
                                  style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w900,
                                      color: _answerVerdictColor(e.value['verdict']))),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(e.value['question'] ?? '',
                                style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white))),
                          ]),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _answerVerdictColor(e.value['verdict']).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(e.value['verdict'] ?? 'OK',
                                style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w800,
                                    color: _answerVerdictColor(e.value['verdict']))),
                          ),
                          if (e.value['feedback'] != null) ...[
                            const SizedBox(height: 8),
                            Text(e.value['feedback'],
                                style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.7), height: 1.4)),
                          ],
                        ],
                      )),
                    )),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity, height: 54,
                    child: ElevatedButton(
                      onPressed: widget.onRestart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C5CFF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: Text("Попробовать снова",
                          style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
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

  Color _answerVerdictColor(String? v) {
    if (v == 'Красный флаг') return Colors.redAccent;
    if (v == 'Слабый ответ') return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  Widget _buildTabs() => Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    ),
    child: Row(children: [_tabBtn("Обзор", 0), _tabBtn("По вопросам", 1)]),
  );

  Widget _tabBtn(String label, int index) {
    final sel = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF7C5CFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800,
                  color: sel ? Colors.white : Colors.white.withValues(alpha: 0.4))),
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    ),
    padding: const EdgeInsets.all(18),
    child: child,
  );

  Widget _title(String t) => Text(t,
      style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white));

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
            Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5, right: 10),
                decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
            Expanded(child: Text(item,
                style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.75), height: 1.4))),
          ],
        ),
      )),
    ],
  );
}