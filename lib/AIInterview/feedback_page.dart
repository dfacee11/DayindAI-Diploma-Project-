import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dayindai/HomePage/widgets/dark_background.dart';

class FeedbackPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final score       = feedback['overallScore'] as int?   ?? 0;
    final strengths   = List<String>.from(feedback['strengths']    ?? []);
    final improvements = List<String>.from(feedback['improvements'] ?? []);
    final verdict     = feedback['verdict']  as String? ?? 'Maybe';
    final summary     = feedback['summary']  as String? ?? '';

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
                  // Score circle
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 130,
                              height: 130,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // White card content
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, 4))]),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (summary.isNotEmpty) ...[
                          Text("Summary", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                          const SizedBox(height: 8),
                          Text(summary, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF64748B), height: 1.5)),
                          const SizedBox(height: 20),
                        ],

                        if (strengths.isNotEmpty) ...[
                          _buildSection("✅ Strengths", strengths, const Color(0xFF22C55E)),
                          const SizedBox(height: 20),
                        ],

                        if (improvements.isNotEmpty)
                          _buildSection("📈 Areas to Improve", improvements, const Color(0xFF7C5CFF)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Restart button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: onRestart,
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

  Widget _buildSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        const SizedBox(height: 10),
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
}