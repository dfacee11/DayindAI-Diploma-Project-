import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const TextInputBar(
      {super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: TextField(
              controller: controller,
              style: GoogleFonts.montserrat(
                  color: Colors.white, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: "Type your answer...",
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onSend,
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)],
              ),
            ),
            child:
                const Icon(Icons.send_rounded, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }
}
