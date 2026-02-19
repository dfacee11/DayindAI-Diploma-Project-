import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dayindai/AnalyzeResume/widgets/white_card.dart';

class KeywordBlock extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool good;

  const KeywordBlock({
    super.key,
    required this.title,
    required this.items,
    required this.good,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items.isEmpty
                  ? [Text("No data yet.", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)))]
                  : items.map((e) => _buildChip(e)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: good ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: good ? const Color(0xFF86EFAC) : const Color(0xFFFED7AA),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: good ? const Color(0xFF14532D) : const Color(0xFF9A3412),
        ),
      ),
    );
  }
}