import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../AiInterview/widgets/call_like_center.dart';
import '../../AiInterview/widgets/chat_bubble.dart';
import '../../AiInterview/widgets/voice_input_bar.dart';
import '../../AiInterview/widgets/text_input_bar.dart';
import '../visa_page.dart';

class VisaChatUI extends StatefulWidget {
  final VisaInterviewProvider provider;

  const VisaChatUI({super.key, required this.provider});

  @override
  State<VisaChatUI> createState() => _VisaChatUIState();
}

class _VisaChatUIState extends State<VisaChatUI> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;

    return Column(
      children: [
        // Status row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.isRecording
                        ? Colors.redAccent
                        : p.isAiSpeaking
                            ? const Color(0xFF7C5CFF)
                            : p.isThinking
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(width: 8),
                Text(p.statusText, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.85))),
              ],
            ),
            Text("Q ${p.questionIndex + 1}/${p.totalQ}", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.6))),
          ],
        ),

        const SizedBox(height: 12),

        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: p.showTranscript
                ? ListView.builder(
                    key: const ValueKey("transcript"),
                    controller: _scrollController,
                    itemCount: p.messages.length,
                    padding: const EdgeInsets.only(bottom: 12),
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ChatBubble(message: p.messages[i]),
                    ),
                  )
                : CallLikeCenter(aiIsSpeaking: p.isAiSpeaking),
          ),
        ),

        const SizedBox(height: 14),

        if (!p.voiceMode)
          TextInputBar(
            controller: _textController,
            onSend: () {
              p.sendText(_textController.text);
              _textController.clear();
            },
          )
        else
          VoiceInputBar(
            aiIsSpeaking: p.isAiSpeaking,
            isThinking: p.isThinking,
            isRecording: p.isRecording,
            onToggle: p.toggleRecording,
          ),
      ],
    );
  }
}