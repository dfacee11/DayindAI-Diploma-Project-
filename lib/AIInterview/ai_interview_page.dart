import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../HomePage/widgets/dark_background.dart';
import 'models/chat_message.dart';
import 'widgets/intro_ui.dart';
import 'widgets/interview_ui.dart';

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
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _speakAi(String text) async {
    setState(() => aiIsSpeaking = true);
    await Future.delayed(Duration(milliseconds: 900 + (text.length * 10)));
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

    setState(
        () => _messages.add(ChatMessage(isUser: false, text: firstQuestion)));
    await _speakAi(firstQuestion);
  }

  Future<void> _sendVoiceTranscript(String transcript) async {
    final text = transcript.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(isUser: true, text: text));
      isThinking = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 700));

    const aiText =
        "Great. Now tell me: why do you want this position and what makes you a strong candidate?";
    if (!mounted) return;

    setState(() {
      _messages.add(ChatMessage(isUser: false, text: aiText));
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
      _messages.add(ChatMessage(isUser: true, text: text));
      _textController.clear();
      isThinking = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 700));

    const aiText =
        "Thank you for sharing. Next question: What are your greatest strengths?";
    if (!mounted) return;

    setState(() {
      _messages.add(ChatMessage(isUser: false, text: aiText));
      isThinking = false;
    });
    _scrollToBottom();
    await _speakAi(aiText);
  }

  void _toggleMode() => setState(() => voiceMode = !voiceMode);

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
    _sendVoiceTranscript("I'm ready. Let's continue the interview.");
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

  String get _statusText {
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
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          const DarkTopBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: started
                  ? InterviewUI(
                      statusText: _statusText,
                      showTranscript: showTranscript,
                      voiceMode: voiceMode,
                      aiIsSpeaking: aiIsSpeaking,
                      isThinking: isThinking,
                      isRecording: isRecording,
                      messages: _messages,
                      scrollController: _scrollController,
                      textController: _textController,
                      onSendMessage: _sendMessage,
                      onToggleRecording: _toggleRecording,
                    )
                  : IntroUI(onStart: _startInterview),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: Text(
        "AI Interview",
        style: GoogleFonts.montserrat(
            fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      actions: started
          ? [
              IconButton(
                icon: Icon(showTranscript
                    ? Icons.visibility_off_rounded
                    : Icons.chat_bubble_rounded),
                onPressed: _toggleTranscript,
                tooltip: showTranscript ? "Hide transcript" : "Show transcript",
              ),
              IconButton(
                icon: Icon(
                    voiceMode ? Icons.keyboard_rounded : Icons.mic_rounded),
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
    );
  }
}
