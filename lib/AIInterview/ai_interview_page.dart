import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../HomePage/widgets/dark_background.dart';
import 'voice_interview_provider.dart';
import 'feedback_page.dart';
import 'widgets/intro_ui.dart';
import 'widgets/interview_ui.dart';

class AiInterviewPage extends StatelessWidget {
  const AiInterviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoiceInterviewProvider(),
      child: const _AiInterviewView(),
    );
  }
}

class _AiInterviewView extends StatelessWidget {
  const _AiInterviewView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<VoiceInterviewProvider>();

    if (p.isFinished && p.feedback != null) {
      return FeedbackPage(
        feedback: p.feedback!,
        jobRole: p.jobRole,
        onRestart: p.restart,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, p),
      body: Stack(
        children: [
          const DarkTopBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: p.started
                  ? InterviewUI(
                      statusText:       p.statusText,
                      showTranscript:   p.showTranscript,
                      voiceMode:        p.voiceMode,
                      aiIsSpeaking:     p.isAiSpeaking,
                      isThinking:       p.isThinking,
                      isRecording:      p.isRecording,
                      messages:         p.messages,
                      scrollController: ScrollController(),
                      textController:   TextEditingController(),
                      onSendMessage:    () {},
                      onToggleRecording: p.toggleRecording,
                      questionIndex:    p.questionIndex,
                      totalQuestions:   p.totalQuestions,
                    )
                  : IntroUI(onStart: p.startInterview),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, VoiceInterviewProvider p) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: p.started
          ? _ProgressTitle(current: p.questionIndex, total: p.totalQuestions)
          : Text("AI Interview", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
      actions: p.started
          ? [
              IconButton(
                icon: Icon(p.showTranscript ? Icons.visibility_off_rounded : Icons.chat_bubble_rounded),
                onPressed: p.toggleTranscript,
                tooltip: "Transcript",
              ),
              IconButton(
                icon: Icon(p.voiceMode ? Icons.keyboard_rounded : Icons.mic_rounded),
                onPressed: p.toggleMode,
                tooltip: "Switch mode",
              ),
              // Кнопка завершить досрочно
              IconButton(
                icon: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent),
                onPressed: () => _confirmFinish(context, p),
                tooltip: "Finish & Get Feedback",
              ),
            ]
          : null,
    );
  }

  void _confirmFinish(BuildContext context, VoiceInterviewProvider p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Finish Interview?", style: GoogleFonts.montserrat(fontWeight: FontWeight.w900)),
        content: Text(
          "You've answered ${p.questionIndex} of ${p.totalQuestions} questions.\nYou'll still get an AI feedback report.",
          style: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Continue", style: GoogleFonts.montserrat(color: const Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              p.finishEarly();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C5CFF), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text("Finish", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _ProgressTitle extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressTitle({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("AI Interview", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 4),
        Row(
          children: [
            SizedBox(
              width: 110,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: total > 0 ? current / total : 0,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFF)),
                  minHeight: 5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "$current/$total",
              style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ],
    );
  }
}