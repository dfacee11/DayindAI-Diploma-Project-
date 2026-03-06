import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tool_item.dart';
import 'feature_tile.dart';

class ToolsSection extends StatelessWidget {
  final String title;
  final List<ToolItem> tools;
  final bool useGrid;

  const ToolsSection({
    super.key,
    required this.title,
    required this.tools,
    this.useGrid = false,
  });

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
        if (!useGrid)
          ...tools.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FeatureTile(tool: t),
              ))
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: tools.map((t) => _GridCard(tool: t)).toList(),
          ),
      ],
    );
  }
}

class _GridCard extends StatelessWidget {
  final ToolItem tool;
  const _GridCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tool.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(tool.icon, color: tool.color, size: 22),
            ),
            const Spacer(),
            Text(
              tool.title,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              tool.subtitle,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '→',
              style: TextStyle(
                fontSize: 16,
                color: tool.color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}