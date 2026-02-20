import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/chat_message.dart';
import 'call_like_center.dart';
import 'chat_bubble.dart';
import 'text_input_bar.dart';
import 'voice_input_bar.dart';

class InterviewUI extends StatelessWidget {
  final String statusText;
  final bool showTranscript;
  final bool voiceMode;
  final bool aiIsSpeaking;
  final bool isThinking;
  final bool isRecording;
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final TextEditingController textController;
  final VoidCallback onSendMessage;
  final VoidCallback onToggleRecording;
  final int questionIndex;
  final int totalQuestions;

  const InterviewUI({
    super.key,
    required this.statusText,
    required this.showTranscript,
    required this.voiceMode,
    required this.aiIsSpeaking,
    required this.isThinking,
    required this.isRecording,
    required this.messages,
    required this.scrollController,
    required this.textController,
    required this.onSendMessage,
    required this.onToggleRecording,
    required this.questionIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Статус
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording
                        ? Colors.redAccent
                        : aiIsSpeaking
                            ? const Color(0xFF7C5CFF)
                            : isThinking
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ),
            Text(
              "Q $questionIndex/$totalQuestions",
              style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: showTranscript ? _buildTranscript() : CallLikeCenter(aiIsSpeaking: aiIsSpeaking),
          ),
        ),

        const SizedBox(height: 14),

        if (!voiceMode)
          TextInputBar(controller: textController, onSend: onSendMessage)
        else
          VoiceInputBar(
            aiIsSpeaking: aiIsSpeaking,
            isThinking: isThinking,
            isRecording: isRecording,
            onToggle: onToggleRecording,
          ),
      ],
    );
  }

  Widget _buildTranscript() {
    return ListView.builder(
      key: const ValueKey("transcript"),
      controller: scrollController,
      itemCount: messages.length,
      padding: const EdgeInsets.only(bottom: 12),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ChatBubble(message: messages[index]),
      ),
    );
  }
}