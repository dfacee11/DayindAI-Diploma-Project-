import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceInputBar extends StatelessWidget {
  final bool aiIsSpeaking;
  final bool isThinking;
  final bool isRecording;
  final VoidCallback onToggle;

  const VoiceInputBar({
    super.key,
    required this.aiIsSpeaking,
    required this.isThinking,
    required this.isRecording,
    required this.onToggle,
  });

  String get _statusLabel {
    if (aiIsSpeaking) return "AI is speaking...";
    if (isRecording) return "Listening... tap to stop";
    return "Tap to answer with voice";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatusRow(),
        const SizedBox(height: 10),
        _buildRecordButton(),
      ],
    );
  }

  Widget _buildStatusRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Icon(
              isRecording ? Icons.graphic_eq_rounded : Icons.mic_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusLabel,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Text(
              isRecording ? "STOP" : "REC",
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (isThinking || aiIsSpeaking) ? null : onToggle,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isRecording ? const Color(0xFFFF3B30) : const Color(0xFF7C5CFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Text(
          isRecording ? "Stop Recording" : "Start Recording",
          style:
              GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
