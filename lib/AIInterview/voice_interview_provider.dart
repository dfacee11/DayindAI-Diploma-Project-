import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'models/chat_message.dart';
import 'interview_service.dart';
import 'widgets/intro_ui.dart';

enum InterviewState { idle, aiSpeaking, userTurn, recording, thinking, finished }

class VoiceInterviewProvider extends ChangeNotifier {
  final InterviewService _service = InterviewService();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  InterviewState state = InterviewState.idle;
  bool started = false;
  bool showTranscript = false;
  bool voiceMode = true;

  final List<ChatMessage> messages = [];
  final List<Map<String, String>> _history = [];

  String jobRole = "Software Engineer";
  InterviewType interviewType = InterviewType.mixed;
  InterviewLanguage language = InterviewLanguage.english;
  int questionIndex = 0;
  int totalQuestions = 7;

  Map<String, dynamic>? feedback;
  String? recordingPath;

  bool get isAiSpeaking => state == InterviewState.aiSpeaking;
  bool get isThinking   => state == InterviewState.thinking;
  bool get isRecording  => state == InterviewState.recording;
  bool get isFinished   => state == InterviewState.finished;

  String get statusText {
    switch (language) {
      case InterviewLanguage.russian:
        switch (state) {
          case InterviewState.aiSpeaking: return "ИИ говорит...";
          case InterviewState.thinking:   return "ИИ думает...";
          case InterviewState.recording:  return "Слушаю...";
          case InterviewState.finished:   return "Интервью завершено!";
          default:                        return "Ваша очередь — нажмите микрофон";
        }
      case InterviewLanguage.kazakh:
        switch (state) {
          case InterviewState.aiSpeaking: return "ЖИ сөйлеп жатыр...";
          case InterviewState.thinking:   return "ЖИ ойлап жатыр...";
          case InterviewState.recording:  return "Тыңдап жатырмын...";
          case InterviewState.finished:   return "Сұхбат аяқталды!";
          default:                        return "Сіздің кезегіңіз — микрофонды басыңыз";
        }
      default:
        switch (state) {
          case InterviewState.aiSpeaking: return "AI is speaking...";
          case InterviewState.thinking:   return "AI is thinking...";
          case InterviewState.recording:  return "Listening...";
          case InterviewState.finished:   return "Interview complete!";
          default:                        return "Your turn — tap mic to speak";
        }
    }
  }

  String get _openingMessage {
    switch (language) {
      case InterviewLanguage.russian:
        return "Привет! Добро пожаловать на интервью. Для начала расскажите немного о себе — кто вы и какой у вас опыт?";
      case InterviewLanguage.kazakh:
        return "Сәлем! Сұхбатқа қош келдіңіз. Басталайық — өзіңіз туралы аздап айтып беріңізші?";
      default:
        return "Hello! Welcome to your interview. Let's start — could you tell me a little about yourself?";
    }
  }

  // ─── START ───
  Future<void> startInterview(String role, InterviewType type, int count, InterviewLanguage lang) async {
    jobRole = role;
    interviewType = type;
    totalQuestions = count;
    language = lang;
    started = true;
    questionIndex = 0;
    messages.clear();
    _history.clear();
    feedback = null;
    notifyListeners();

    await _aiSpeak(_openingMessage);
  }

  // ─── FINISH EARLY ───
  Future<void> finishEarly() async {
    if (state == InterviewState.recording) await _recorder.stop();
    await _player.stop();

    if (_history.isEmpty) {
      state = InterviewState.idle;
      started = false;
      notifyListeners();
      return;
    }

    state = InterviewState.thinking;
    notifyListeners();
    await _loadFeedback();
    state = InterviewState.finished;
    notifyListeners();
  }


  Future<void> _aiSpeak(String text) async {
    state = InterviewState.aiSpeaking;
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

    if (state == InterviewState.aiSpeaking) {
      state = InterviewState.userTurn;
      notifyListeners();
    }
  }


  Future<void> _playAudio(String base64) async {
    try {
      final bytes = base64Decode(base64);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ai_speech_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await file.writeAsBytes(bytes);

      await _player.stop();
      await _player.setFilePath(file.path);
      await _player.seek(Duration.zero);
      await _player.play();

      // Ждём завершения через playerStateStream — надёжнее чем processingStateStream
      await _player.playerStateStream.firstWhere(
        (s) => s.processingState == ProcessingState.completed || !s.playing,
      );
    } catch (e) {
      debugPrint('Audio play error: $e');
    }
  }

  Future<void> toggleRecording() async {
    if (state != InterviewState.userTurn && state != InterviewState.recording) return;
    HapticFeedback.lightImpact();

    if (state == InterviewState.recording) {
      await _stopRecordingAndProcess();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    recordingPath = '${dir.path}/user_answer.m4a';

    await _recorder.start(
      RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 32000, sampleRate: 16000),
      path: recordingPath!,
    );

    state = InterviewState.recording;
    notifyListeners();
  }

  Future<void> _stopRecordingAndProcess() async {
    await _recorder.stop();
    state = InterviewState.thinking;
    notifyListeners();

    try {
      final audioBytes = await File(recordingPath!).readAsBytes();
      final audioBase64 = base64Encode(audioBytes);
      final transcript = await _service.transcribeAudio(
        audioBase64,
        languageCode: language.whisperCode,
      );

      if (transcript.trim().isEmpty) {
        state = InterviewState.userTurn;
        notifyListeners();
        return;
      }

      messages.add(ChatMessage(isUser: true, text: transcript));
      _history.add({'role': 'user', 'content': transcript});
      notifyListeners();

      await _getAiReply();
    } catch (e) {
      debugPrint('STT error: $e');
      state = InterviewState.userTurn;
      notifyListeners();
    }
  }

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    if (state == InterviewState.aiSpeaking || state == InterviewState.thinking) return;

    messages.add(ChatMessage(isUser: true, text: text));
    _history.add({'role': 'user', 'content': text});
    state = InterviewState.thinking;
    notifyListeners();

    await _getAiReply();
  }

  Future<void> _getAiReply() async {
    try {
      final result = await _service.interviewChat(
        messages: List.from(_history),
        jobRole: jobRole,
        interviewTypeHint: interviewType.systemPromptHint,
        languageInstruction: language.systemLanguageInstruction,
        questionIndex: questionIndex,
        totalQuestions: totalQuestions,
      );

      final reply = result['reply'] as String? ?? '';
      questionIndex++;

      if (questionIndex >= totalQuestions) {
        await _aiSpeak(reply);
        state = InterviewState.thinking;
        notifyListeners();
        await _loadFeedback();
        state = InterviewState.finished;
        notifyListeners();
      } else {
        await _aiSpeak(reply);
      }
    } catch (e) {
      debugPrint('GPT error: $e');
      state = InterviewState.userTurn;
      notifyListeners();
    }
  }


  Future<void> _loadFeedback() async {
    try {
      feedback = await _service.interviewFeedback(
        messages: List.from(_history),
        jobRole: jobRole,
        languageInstruction: language.systemLanguageInstruction,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Feedback error: $e');
      feedback = {
        'overallScore': 0,
        'strengths': [],
        'improvements': [],
        'verdict': 'Maybe',
        'summary': 'Could not generate feedback.',
      };
      notifyListeners();
    }
  }

  void toggleTranscript() { showTranscript = !showTranscript; notifyListeners(); }
  void toggleMode()        { voiceMode = !voiceMode; notifyListeners(); }

  void restart() {
    state = InterviewState.idle;
    started = false;
    messages.clear();
    _history.clear();
    feedback = null;
    questionIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}