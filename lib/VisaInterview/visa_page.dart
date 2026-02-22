import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../HomePage/widgets/dark_background.dart';
import 'visa_interview_provider.dart';
import 'visa_feedback_page.dart';
import 'widgets/visa_city_selector.dart';
import 'widgets/visa_chat_ui.dart';

class VisaPage extends StatelessWidget {
  const VisaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisaInterviewProvider(),
      child: const _VisaView(),
    );
  }
}

class _VisaView extends StatelessWidget {
  const _VisaView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<VisaInterviewProvider>();

    if (p.isFinished && p.feedback != null) {
      return VisaFeedbackPage(
        feedback: p.feedback!,
        city: p.city,
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
                  ? VisaChatUI(provider: p)
                  : VisaCitySelector(onStart: p.startInterview),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, VisaInterviewProvider p) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: p.started
          ? _ProgressTitle(current: p.questionIndex, total: p.totalQ, city: p.city)
          : Text("🇺🇸 Work & Travel",
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
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
                icon: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent),
                onPressed: () => _confirmFinish(context, p),
              ),
            ]
          : null,
    );
  }

  void _confirmFinish(BuildContext context, VisaInterviewProvider p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Завершить интервью?",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w900)),
        content: Text(
          "Вы ответили на ${p.questionIndex} из ${p.totalQ} вопросов.\nВсё равно получите анализ.",
          style: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Продолжить",
                style: GoogleFonts.montserrat(color: const Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); p.finishEarly(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C5CFF),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text("Завершить",
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _ProgressTitle extends StatelessWidget {
  final int current;
  final int total;
  final VisaCity city;

  const _ProgressTitle({required this.current, required this.total, required this.city});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${city.flag} ${city.displayName} Consulate",
            style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
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
            Text("$current/$total",
                style: GoogleFonts.montserrat(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ],
    );
  }
}