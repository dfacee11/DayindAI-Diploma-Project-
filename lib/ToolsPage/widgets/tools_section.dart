import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tool_item.dart';
import 'feature_tile.dart';

class ToolsSection extends StatelessWidget {
  final String title;
  final List<ToolItem> tools;

  const ToolsSection({super.key, required this.title, required this.tools});

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 12),
        ...tools.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FeatureTile(tool: t),
            )),
      ],
    );
  }
}
