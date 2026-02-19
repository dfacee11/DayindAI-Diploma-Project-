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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            statusText,
            style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.85)),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: showTranscript
                ? _buildTranscript()
                : CallLikeCenter(aiIsSpeaking: aiIsSpeaking),
          ),
        ),
        const SizedBox(height: 14),
        if (!voiceMode)
          TextInputBar(
            controller: textController,
            onSend: onSendMessage,
          )
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
