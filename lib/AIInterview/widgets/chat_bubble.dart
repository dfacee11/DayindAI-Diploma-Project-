import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: message.isUser ? _userDecoration() : _aiDecoration(),
        child: Text(
          message.text,
          style: GoogleFonts.montserrat(
            color: message.isUser ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  BoxDecoration _userDecoration() => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(18)),
      );

  BoxDecoration _aiDecoration() => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      );
}
