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

    // Показываем feedback страницу когда интервью закончено
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
                      statusText:      p.statusText,
                      showTranscript:  p.showTranscript,
                      voiceMode:       p.voiceMode,
                      aiIsSpeaking:    p.isAiSpeaking,
                      isThinking:      p.isThinking,
                      isRecording:     p.isRecording,
                      messages:        p.messages,
                      scrollController: ScrollController(),
                      textController:  TextEditingController(),
                      onSendMessage:   () {},
                      onToggleRecording: p.toggleRecording,
                      // прогресс
                      questionIndex:   p.questionIndex,
                      totalQuestions:  VoiceInterviewProvider.totalQuestions,
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
          ? _ProgressTitle(current: p.questionIndex, total: VoiceInterviewProvider.totalQuestions)
          : Text("AI Interview", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
      actions: p.started
          ? [
              IconButton(
                icon: Icon(p.showTranscript ? Icons.visibility_off_rounded : Icons.chat_bubble_rounded),
                onPressed: p.toggleTranscript,
              ),
              IconButton(
                icon: Icon(p.voiceMode ? Icons.keyboard_rounded : Icons.mic_rounded),
                onPressed: p.toggleMode,
              ),
              IconButton(
                icon: const Icon(Icons.call_end_rounded, color: Colors.redAccent),
                onPressed: () => Navigator.pop(context),
              ),
            ]
          : null,
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
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: current / total,
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