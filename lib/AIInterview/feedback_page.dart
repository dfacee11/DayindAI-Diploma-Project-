import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dayindai/HomePage/widgets/dark_background.dart';

class FeedbackPage extends StatefulWidget {
  final Map<String, dynamic> feedback;
  final String jobRole;
  final VoidCallback onRestart;

  const FeedbackPage({
    super.key,
    required this.feedback,
    required this.jobRole,
    required this.onRestart,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final f = widget.feedback;
    final score        = f['overallScore'] as int?    ?? 0;
    final verdict      = f['verdict']     as String?  ?? 'Maybe';
    final summary      = f['summary']     as String?  ?? '';
    final strengths    = List<String>.from(f['strengths']    ?? []);
    final improvements = List<String>.from(f['improvements'] ?? []);
    final tips         = List<String>.from(f['tips']         ?? []);
    final categories   = f['categories']  as Map?     ?? {};
    final answers      = List<Map>.from(f['answerAnalysis'] ?? []);

    final verdictColor = verdict == 'Hire'
        ? const Color(0xFF22C55E)
        : verdict == 'No Hire'
            ? Colors.redAccent
            : const Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text("Interview Results", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
      body: Stack(
        children: [
          const DarkTopBackground(),
          Positioned(top: 200, left: 0, right: 0, bottom: 0, child: Container(color: const Color(0xFFF4F5FA))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── SCORE + VERDICT ──
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
                                Text('/100', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(color: verdictColor, borderRadius: BorderRadius.circular(20)),
                          child: Text(verdict, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                        if (summary.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            summary,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.8), height: 1.5),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── CATEGORY SCORES ──
                  if (categories.isNotEmpty) ...[
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _cardTitle("📊 Category Scores"),
                          const SizedBox(height: 14),
                          ...categories.entries.map((e) {
                            final val = (e.value as num).toInt();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(e.key, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                                      Text('$val/100', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w800, color: _scoreColor(val))),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: val / 100,
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(val)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── TABS: Overview / Per Answer ──
                  if (answers.isNotEmpty) ...[
                    _buildTabSelector(),
                    const SizedBox(height: 14),
                  ],

                  if (_selectedTab == 0 || answers.isEmpty) ...[
                    // ── STRENGTHS ──
                    if (strengths.isNotEmpty) ...[
                      _buildCard(
                        child: _buildBulletSection("✅ Strengths", strengths, const Color(0xFF22C55E)),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── IMPROVEMENTS ──
                    if (improvements.isNotEmpty) ...[
                      _buildCard(
                        child: _buildBulletSection("📈 Areas to Improve", improvements, const Color(0xFF7C5CFF)),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── TIPS ──
                    if (tips.isNotEmpty) ...[
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _cardTitle("💡 What to Say Better"),
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
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],

                  // ── PER ANSWER TAB ──
                  if (_selectedTab == 1 && answers.isNotEmpty) ...[
                    ...answers.asMap().entries.map((e) {
                      final i = e.key;
                      final a = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFF7C5CFF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                    child: Text('Q${i + 1}', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF7C5CFF))),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(a['question'] ?? '', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)))),
                                ],
                              ),
                              if (a['score'] != null) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text('Score: ', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                                    Text('${a['score']}/100', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w900, color: _scoreColor((a['score'] as num).toInt()))),
                                  ],
                                ),
                              ],
                              if (a['feedback'] != null) ...[
                                const SizedBox(height: 8),
                                Text(a['feedback'], style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF475569), height: 1.4)),
                              ],

                            ],
                          ),
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 6),

                  // ── RESTART ──
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: widget.onRestart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C5CFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: Text("Practice Again", style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900)),
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

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
      child: Row(
        children: [
          _tab("Overview", 0),
          _tab("Per Answer", 1),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF7C5CFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: selected ? Colors.white : const Color(0xFF94A3B8))),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black.withValues(alpha: 0.04), offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }

  Widget _cardTitle(String title) {
    return Text(title, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)));
  }

  Widget _buildBulletSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardTitle(title),
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
  }

  Color _scoreColor(int score) {
    if (score >= 75) return const Color(0xFF22C55E);
    if (score >= 50) return const Color(0xFFF59E0B);
    return Colors.redAccent;
  }
}