import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToolsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const ToolsSearchBar({super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(blurRadius: 8, offset: const Offset(0, 2), color: Colors.black.withValues(alpha: 0.04)),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
          hintText: "Search tools...",
          hintStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}