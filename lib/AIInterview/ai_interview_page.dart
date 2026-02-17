import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class AiInterviewPage extends StatefulWidget {
  const AiInterviewPage({super.key});

  @override
  State<AiInterviewPage> createState() => _AiInterviewPageState();
}

class _AiInterviewPageState extends State<AiInterviewPage> {
  bool started = false;

  bool isThinking = false;
  bool aiIsSpeaking = false;

  bool isRecording = false;
  bool voiceMode = true;

  bool showTranscript = false;

  final TextEditingController _textController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _speakAi(String text) async {
    // TODO: Here we will connect TTS later.
    // For now: fake speaking delay
    setState(() => aiIsSpeaking = true);

    await Future.delayed(
      Duration(milliseconds: 900 + (text.length * 10)),
    );

    if (!mounted) return;
    setState(() => aiIsSpeaking = false);
  }

  Future<void> _startInterview() async {
    setState(() {
      started = true;
      _messages.clear();
      isThinking = false;
      isRecording = false;
      showTranscript = false;
    });

    const firstQuestion =
        "Hello! Welcome to the interview. Let's start with an easy question: Can you tell me about yourself?";

    setState(() {
      _messages.add(_ChatMessage(isUser: false, text: firstQuestion));
    });

    await _speakAi(firstQuestion);
  }

  void _toggleMode() {
    setState(() {
      voiceMode = !voiceMode;
    });
  }

  void _toggleTranscript() {
    setState(() => showTranscript = !showTranscript);
    if (showTranscript) _scrollToBottom();
  }

  Future<void> _toggleRecording() async {
    if (aiIsSpeaking || isThinking) return;

    if (!isRecording) {
      setState(() => isRecording = true);
      HapticFeedback.lightImpact();
      return;
    }

    setState(() => isRecording = false);
    HapticFeedback.lightImpact();

    // Fake recognized speech -> send
    _sendVoiceTranscript("I’m ready. Let’s continue the interview.");
  }

  Future<void> _sendVoiceTranscript(String transcript) async {
    final text = transcript.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text));
      isThinking = true;
    });
    _scrollToBottom();

    // Fake AI response
    await Future.delayed(const Duration(milliseconds: 700));

    const aiText =
        "Great. Now tell me: why do you want this position and what makes you a strong candidate?";

    if (!mounted) return;

    setState(() {
      _messages.add(_ChatMessage(isUser: false, text: aiText));
      isThinking = false;
    });
    _scrollToBottom();

    await _speakAi(aiText);
  }

  Future<void> _sendMessage() async {
    if (aiIsSpeaking || isThinking) return;

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text));
      _textController.clear();
      isThinking = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 700));

    const aiText =
        "Thank you for sharing. Next question: What are your greatest strengths?";

    if (!mounted) return;

    setState(() {
      _messages.add(_ChatMessage(isUser: false, text: aiText));
      isThinking = false;
    });
    _scrollToBottom();

    await _speakAi(aiText);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getStatusText() {
    if (aiIsSpeaking) return "AI is speaking...";
    if (isThinking) return "AI is thinking...";
    if (isRecording) return "Listening...";
    return "Your turn";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          "AI Interview",
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        actions: started
            ? [
                IconButton(
                  icon: Icon(showTranscript
                      ? Icons.visibility_off_rounded
                      : Icons.chat_bubble_rounded),
                  onPressed: _toggleTranscript,
                  tooltip:
                      showTranscript ? "Hide transcript" : "Show transcript",
                ),
                IconButton(
                  icon: Icon(
                    voiceMode ? Icons.keyboard_rounded : Icons.mic_rounded,
                  ),
                  onPressed: _toggleMode,
                  tooltip: voiceMode ? "Switch to typing" : "Switch to voice",
                ),
                IconButton(
                  icon: const Icon(Icons.call_end_rounded),
                  onPressed: () => Navigator.pop(context),
                  tooltip: "End Interview",
                ),
              ]
            : null,
      ),
      body: Stack(
        children: [
          const _DarkTopBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: started ? _buildInterviewUI() : _buildIntroUI(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.04),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Center(
                  child: Image.asset(
                    "assets/images/aipenguin.png",
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Classic Interview",
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "AI speaks like a real interviewer.\nTranscript is optional.",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.70),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _startInterview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C5CFF),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: Text(
              "Start Interview",
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewUI() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _getStatusText(),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: showTranscript ? _buildTranscript() : _buildCallLikeCenter(),
          ),
        ),
        const SizedBox(height: 14),
        if (!voiceMode) _buildTextInput() else _buildVoiceInput(),
      ],
    );
  }

  Widget _buildCallLikeCenter() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: Center(
              child: Image.asset(
                "assets/images/aipenguin.png",
                width: 120,
                height: 120,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            aiIsSpeaking ? "Speaking..." : "Waiting...",
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap transcript icon if you want to read.",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscript() {
    return ListView.builder(
      key: const ValueKey("transcript"),
      controller: _scrollController,
      itemCount: _messages.length,
      padding: const EdgeInsets.only(bottom: 12),
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _ChatBubble(message: message),
        );
      },
    );
  }

  Widget _buildTextInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: TextField(
              controller: _textController,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: "Type your answer...",
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _sendMessage,
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7C5CFF),
                  Color(0xFF2DD4FF),
                ],
              ),
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceInput() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                ),
                child: Icon(
                  isRecording ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  aiIsSpeaking
                      ? "AI is speaking..."
                      : isRecording
                          ? "Listening... tap to stop"
                          : "Tap to answer with voice",
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.92),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
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
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: (isThinking || aiIsSpeaking) ? null : _toggleRecording,
            style: ElevatedButton.styleFrom(
              backgroundColor: isRecording
                  ? const Color(0xFFFF3B30)
                  : const Color(0xFF7C5CFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(
              isRecording ? "Stop Recording" : "Start Recording",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DarkTopBackground extends StatelessWidget {
  const _DarkTopBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B1220),
            Color(0xFF121A2B),
            Color(0xFF1A2236),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -90,
            child: _BlurBlob(
              size: 320,
              color: Color(0xFF7C5CFF),
              opacity: 0.18,
            ),
          ),
          Positioned(
            top: 140,
            right: -130,
            child: _BlurBlob(
              size: 340,
              color: Color(0xFF2DD4FF),
              opacity: 0.14,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _BlurBlob({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final bool isUser;
  final String text;

  _ChatMessage({
    required this.isUser,
    required this.text,
  });
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7C5CFF),
                Color(0xFF2DD4FF),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            message.text,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.black.withOpacity(0.08),
          ),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
