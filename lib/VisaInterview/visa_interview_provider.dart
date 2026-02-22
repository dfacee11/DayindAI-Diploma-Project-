import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../AiInterview/interview_service.dart';
import '../AiInterview/models/chat_message.dart';
import 'models/visa_city.dart';

export 'models/visa_city.dart';

enum VisaState { idle, aiSpeaking, userTurn, recording, thinking, finished }

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

  // ─── AI SPEAK ───
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
      final ms = (text.length * 50).clamp(1000, 8000);
      await Future.delayed(Duration(milliseconds: ms));
    }

    if (state == VisaState.aiSpeaking) {
      state = VisaState.userTurn;
      notifyListeners();
    }
  }

  // ─── AUDIO PLAYBACK ───
  Future<void> _playAudio(String base64) async {
    try {
      final bytes = base64Decode(base64);
      final dir   = await getTemporaryDirectory();
      final file  = File('${dir.path}/visa_speech_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await file.writeAsBytes(bytes);
      await _player.stop();
      await _player.setFilePath(file.path);
      await _player.seek(Duration.zero);
      await _player.play();
      await _player.playerStateStream.firstWhere(
        (s) => s.processingState == ProcessingState.completed || !s.playing,
      );
    } catch (e) {
      debugPrint('Audio play error: $e');
    }
  }

  // ─── RECORDING ───
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
    if (!hasPermission) return;

    final dir      = await getTemporaryDirectory();
    _recordingPath = '${dir.path}/visa_answer.m4a';

    await _recorder.start(
      RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 32000, sampleRate: 16000),
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
      final audioBytes  = await File(_recordingPath!).readAsBytes();
      final audioBase64 = base64Encode(audioBytes);
      final transcript  = await _service.transcribeAudio(audioBase64, languageCode: 'en');

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

  // ─── NEXT QUESTION ───
  Future<void> _nextQuestion() async {
    questionIndex++;
    if (questionIndex >= questions.length) {
      await _aiSpeak("Thank you for your time. That concludes our interview today. Have a great day!");
      state = VisaState.thinking;
      notifyListeners();
      await _loadFeedback();
      state = VisaState.finished;
      notifyListeners();
    } else {
      await _aiSpeak(questions[questionIndex]);
    }
  }

  // ─── FINISH EARLY ───
  Future<void> finishEarly() async {
    if (state == VisaState.recording) await _recorder.stop();
    await _player.stop();

    if (_history.isEmpty) { restart(); return; }

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