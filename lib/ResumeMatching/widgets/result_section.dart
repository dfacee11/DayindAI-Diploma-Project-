import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dayindai/AnalyzeResume/widgets/white_card.dart';
import '../resume_matching_result.dart';
import 'keyword_block.dart';

class ResultSection extends StatelessWidget {
  final ResumeMatchingResult result;

  const ResultSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WhiteCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Match Score", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: result.score / 100,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF7C5CFF)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text("${result.score}%", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        KeywordBlock(title: "Matched keywords", items: result.matched, good: true),
        const SizedBox(height: 12),
        KeywordBlock(title: "Missing keywords",  items: result.missing, good: false),
        const SizedBox(height: 14),
        WhiteCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tips", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                const SizedBox(height: 10),
                ...result.tips.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text("• $t", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B), height: 1.25)),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}