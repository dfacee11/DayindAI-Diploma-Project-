import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../HomePage/widgets/dark_background.dart';
import '../AiInterview/interview_service.dart';
import '../AiInterview/models/chat_message.dart';
import 'widgets/visa_city_selector.dart';
import 'widgets/visa_chat_ui.dart';
import 'visa_feedback_page.dart';

// ─── QUESTIONS ───────────────────────────────────────
const _astanaQuestions = [
  "Where will you work and as what position?",
  "Where are you studying and what is your major?",
  "What is your GPA? Are you happy with it?",
  "Do you have a hobby? Tell me about it.",
  "Have you been abroad before? Where did you go?",
  "Why did you choose this state for Work and Travel?",
  "What do you know about the state you are going to?",
  "What are your responsibilities at your workplace?",
  "What is your purpose of visiting the USA?",
  "What are your future career goals?",
  "Do you know your rights as a J-1 visa holder?",
  "What languages do you speak or learn?",
  "What will you do after returning from the USA?",
  "Where do your parents live? What do they do?",
  "Do you have relatives or friends in the USA?",
  "What is your favorite subject at university?",
  "When will you graduate?",
  "Tell me about your region or city.",
  "Have you participated in Work and Travel before?",
  "What other places do you want to visit in the US?",
  "What do you do in your leisure time?",
  "What kind of music do you listen to?",
  "What is your favorite movie?",
  "Are you a sportsman? What sport do you play?",
  "Where do you want to work in the future after graduation?",
  "How will this Work and Travel experience affect your future career?",
  "What did you do last summer?",
  "Which university do you attend and why did you choose it?",
];

const _almatyQuestions = [
  "Where do you study and what is your major?",
  "Where are you going in the US?",
  "What is your position at work?",
  "What are your responsibilities?",
  "Did you work before? Tell me about your experience.",
  "What are your plans for the future?",
  "What will you do after graduation?",
  "Why do you want to go to the USA?",
  "Tell me about the Work and Travel program.",
  "What is your GPA?",
  "What are your career goals?",
  "What did you do last summer?",
  "Which year of study are you in?",
  "Why did you choose this speciality?",
  "Why did you choose this university?",
  "What will you do after returning from America?",
  "Do you have family or friends in the USA?",
  "What does your father or mother do for a living?",
  "Is this your first time participating in Work and Travel?",
  "What is your favorite film?",
  "What will be your job this summer?",
  "Tell me about your university.",
  "What kind of job do you want to find in the future?",
];

// ─── CITY ────────────────────────────────────────────
enum VisaCity { astana, almaty }

extension VisaCityExt on VisaCity {
  String get displayName => this == VisaCity.astana ? "Астана" : "Алматы";
  String get flag        => this == VisaCity.astana ? "🏛️" : "🏔️";
  int    get minQ        => this == VisaCity.astana ? 6 : 3;
  int    get maxQ        => this == VisaCity.astana ? 9 : 5;

  List<String> get allQuestions =>
      this == VisaCity.astana ? _astanaQuestions : _almatyQuestions;

  List<String> getRandomQuestions() {
    final rng   = Random();
    final count = minQ + rng.nextInt(maxQ - minQ + 1);
    final list  = List<String>.from(allQuestions)..shuffle(rng);
    return list.take(count).toList();
  }
}

// ─── STATE ───────────────────────────────────────────
enum VisaState { idle, aiSpeaking, userTurn, recording, thinking, finished }

// ─── PROVIDER ────────────────────────────────────────
class VisaInterviewProvider extends ChangeNotifier {
  final InterviewService _service  = InterviewService();
  final AudioRecorder    _recorder = AudioRecorder();
  final AudioPlayer      _player   = AudioPlayer();

  VisaState state     = VisaState.idle;
  bool started        = false;
  bool showTranscript = false;
  bool voiceMode      = true;

  VisaCity         city          = VisaCity.astana;
  List<String>     questions     = [];
  int              questionIndex = 0;

  final List<ChatMessage>         messages = [];
  final List<Map<String, String>> _history = [];
  Map<String, dynamic>?           feedback;
  String?                         _recordingPath;

  bool get isAiSpeaking => state == VisaState.aiSpeaking;
  bool get isThinking   => state == VisaState.thinking;
  bool get isRecording  => state == VisaState.recording;
  bool get isFinished   => state == VisaState.finished;
  int  get totalQ       => questions.length;

  String get statusText {
    switch (state) {
      case VisaState.aiSpeaking: return "Консул говорит...";
      case VisaState.thinking:   return "Обработка...";
      case VisaState.recording:  return "Слушаю...";
      case VisaState.finished:   return "Интервью завершено!";
      default:                   return "Ваша очередь — нажмите микрофон";
    }
  }

  // ─── START ───
  Future<void> startInterview(VisaCity selectedCity) async {
    city          = selectedCity;
    questions     = city.getRandomQuestions();
    questionIndex = 0;
    started       = true;
    messages.clear();
    _history.clear();
    feedback = null;
    notifyListeners();

    await _aiSpeak(
      "Hello! I am the consular officer. Please answer my questions clearly and confidently. ${questions[0]}",
    );
  }

  // ─── AI ГОВОРИТ ───
  Future<void> _aiSpeak(String text) async {
    state = VisaState.aiSpeaking;
    messages.add(ChatMessage(isUser: false, text: text));
    _history.add({'role': 'assistant', 'content': text});
    notifyListeners();

    try {
      final audioBase64 = await _service.textToSpeech(text);
      await _playAudio(audioBase64);
    } catch (e) {
      debugPrint('TTS error: $e');
      await Future.delayed(Duration(milliseconds: 600 + text.length * 10));
    }

    if (state != VisaState.finished) {
      state = VisaState.userTurn;
      notifyListeners();
    }
  }

  // ─── ВОСПРОИЗВЕДЕНИЕ ───
  Future<void> _playAudio(String base64) async {
    try {
      final bytes = base64Decode(base64);
      final dir   = await getTemporaryDirectory();
      final file  = File('${dir.path}/visa_speech.mp3');
      await file.writeAsBytes(bytes);
      await _player.setFilePath(file.path);
      await _player.play();
      await _player.processingStateStream
          .firstWhere((s) => s == ProcessingState.completed);
    } catch (e) {
      debugPrint('Audio play error: $e');
    }
  }

  // ─── ЗАПИСЬ ───
  Future<void> toggleRecording() async {
    if (state != VisaState.userTurn && state != VisaState.recording) return;
    HapticFeedback.lightImpact();

    if (state == VisaState.recording) {
      await _stopAndProcess();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      debugPrint('No microphone permission');
      return;
    }

    final dir      = await getTemporaryDirectory();
    _recordingPath = '${dir.path}/visa_answer.m4a';

    await _recorder.start(
      RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
      path: _recordingPath!,
    );

    state = VisaState.recording;
    notifyListeners();
  }

  Future<void> _stopAndProcess() async {
    await _recorder.stop();
    state = VisaState.thinking;
    notifyListeners();

    try {
      if (_recordingPath == null) throw Exception('No recording path');

      final audioBytes  = await File(_recordingPath!).readAsBytes();
      final audioBase64 = base64Encode(audioBytes);

      final transcript = await _service.transcribeAudio(
        audioBase64,
        languageCode: 'en',
      );

      debugPrint('Transcript: $transcript');

      if (transcript.trim().isEmpty) {
        state = VisaState.userTurn;
        notifyListeners();
        return;
      }

      messages.add(ChatMessage(isUser: true, text: transcript));
      _history.add({'role': 'user', 'content': transcript});
      notifyListeners();

      await _nextQuestion();
    } catch (e) {
      debugPrint('STT error: $e');
      state = VisaState.userTurn;
      notifyListeners();
    }
  }

  // ─── TEXT MODE ───
  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    if (state == VisaState.aiSpeaking || state == VisaState.thinking) return;

    messages.add(ChatMessage(isUser: true, text: text));
    _history.add({'role': 'user', 'content': text});
    state = VisaState.thinking;
    notifyListeners();

    await _nextQuestion();
  }

  // ─── СЛЕДУЮЩИЙ ВОПРОС ───
  Future<void> _nextQuestion() async {
    questionIndex++;
    if (questionIndex >= questions.length) {
      await _aiSpeak(
        "Thank you for your time. That concludes our interview today. Have a great day!",
      );
      state = VisaState.thinking;
      notifyListeners();
      await _loadFeedback();
      state = VisaState.finished;
      notifyListeners();
    } else {
      await _aiSpeak(questions[questionIndex]);
    }
  }

  // ─── ДОСРОЧНОЕ ЗАВЕРШЕНИЕ ───
  Future<void> finishEarly() async {
    if (state == VisaState.recording) await _recorder.stop();
    await _player.stop();

    if (_history.isEmpty) {
      restart();
      return;
    }

    state = VisaState.thinking;
    notifyListeners();
    await _loadFeedback();
    state = VisaState.finished;
    notifyListeners();
  }

  // ─── FEEDBACK ───
  Future<void> _loadFeedback() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('visaInterviewFeedback')
          .call({'messages': _history, 'city': city.displayName});
      feedback = Map<String, dynamic>.from(result.data);
    } catch (e) {
      debugPrint('Visa feedback error: $e');
      feedback = {
        'overallScore': 0,
        'verdict': 'Needs Practice',
        'summary': 'Could not generate feedback.',
        'strengths': [],
        'improvements': [],
        'tips': [],
        'answerAnalysis': [],
      };
    }
    notifyListeners();
  }

  void toggleTranscript() { showTranscript = !showTranscript; notifyListeners(); }
  void toggleMode()        { voiceMode = !voiceMode; notifyListeners(); }

  void restart() {
    state         = VisaState.idle;
    started       = false;
    questionIndex = 0;
    messages.clear();
    _history.clear();
    feedback = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}

// ─── MAIN PAGE ───────────────────────────────────────
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
                    fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ],
    );
  }
}