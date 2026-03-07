import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/chat_message.dart';
import 'interview_service.dart';
import 'widgets/intro_ui.dart';

enum InterviewState { idle, aiSpeaking, userTurn, recording, thinking, analyzing, finished, error }

class VoiceInterviewProvider extends ChangeNotifier {
  final InterviewService _service = InterviewService();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _disposed = false;

  InterviewState state = InterviewState.idle;
  bool started = false;
  bool showTranscript = false;
  bool voiceMode = true;

  // ── Ошибка ────────────────────────────────────────────────────────────────
  Object? lastError;
  void clearError() { lastError = null; notifyListeners(); }

  final List<ChatMessage> messages = [];
  final List<Map<String, String>> _history = [];

  String jobRole = "Software Engineer";
  String? jobDescription;
  InterviewType interviewType = InterviewType.mixed;
  InterviewLanguage language = InterviewLanguage.english;
  ExperienceLevel level = ExperienceLevel.junior;
  int questionIndex = 0;
  int totalQuestions = 7;

  Map<String, dynamic>? feedback;
  String? recordingPath;

  bool get isAiSpeaking => state == InterviewState.aiSpeaking;
  bool get isThinking   => state == InterviewState.thinking;
  bool get isRecording  => state == InterviewState.recording;
  bool get isFinished   => state == InterviewState.finished;
  bool get isAnalyzing  => state == InterviewState.analyzing;
  bool get hasError     => state == InterviewState.error;

  String get statusText {
    switch (language) {
      case InterviewLanguage.russian:
        switch (state) {
          case InterviewState.aiSpeaking: return "ИИ говорит...";
          case InterviewState.thinking:   return "ИИ думает...";
          case InterviewState.recording:  return "Слушаю...";
          case InterviewState.finished:   return "Интервью завершено!";
          case InterviewState.error:      return "Ошибка соединения";
          default:                        return "Ваша очередь — нажмите микрофон";
        }
      case InterviewLanguage.kazakh:
        switch (state) {
          case InterviewState.aiSpeaking: return "ЖИ сөйлеп жатыр...";
          case InterviewState.thinking:   return "ЖИ ойлап жатыр...";
          case InterviewState.recording:  return "Тыңдап жатырмын...";
          case InterviewState.finished:   return "Сұхбат аяқталды!";
          case InterviewState.error:      return "Қосылым қатесі";
          default:                        return "Сіздің кезегіңіз — микрофонды басыңыз";
        }
      default:
        switch (state) {
          case InterviewState.aiSpeaking: return "AI is speaking...";
          case InterviewState.thinking:   return "AI is thinking...";
          case InterviewState.recording:  return "Listening...";
          case InterviewState.finished:   return "Interview complete!";
          case InterviewState.error:      return "Connection error";
          default:                        return "Your turn — tap mic to speak";
        }
    }
  }

  String get _openingMessage {
    switch (language) {
      case InterviewLanguage.russian:
        return jobDescription != null
            ? "Привет! Я изучил описание вакансии. Начнём интервью — расскажите немного о себе."
            : "Привет! Добро пожаловать на интервью для ${level.label} ${jobRole}. Для начала расскажите немного о себе.";
      case InterviewLanguage.kazakh:
        return jobDescription != null
            ? "Сәлем! Мен жұмыс сипаттамасын оқыдым. Сұхбатты бастайық — өзіңіз туралы айтып беріңіз."
            : "Сәлем! ${level.label} ${jobRole} лауазымына сұхбатқа қош келдіңіз. Өзіңіз туралы айтып беріңізші.";
      default:
        return jobDescription != null
            ? "Hello! I've reviewed the job description. Let's start — could you tell me a little about yourself?"
            : "Hello! Welcome to your ${level.label} ${jobRole} interview. Let's start — could you tell me a little about yourself?";
    }
  }

  // ─── START ───────────────────────────────────────────────────────────────
  Future<void> startInterview(
    String role,
    InterviewType type,
    int count,
    InterviewLanguage lang,
    ExperienceLevel lvl,
    String? jd,
  ) async {
    jobRole = role;
    jobDescription = jd;
    interviewType = type;
    totalQuestions = count;
    language = lang;
    level = lvl;
    started = true;
    questionIndex = 0;
    messages.clear();
    _history.clear();
    feedback = null;
    lastError = null;
    _notify();

    await _aiSpeak(_openingMessage);
  }

  // ─── FINISH EARLY ─────────────────────────────────────────────────────────
  Future<void> finishEarly() async {
    if (state == InterviewState.recording) await _recorder.stop();
    await _player.stop();

    if (_history.isEmpty) {
      state = InterviewState.idle;
      started = false;
      _notify();
      return;
    }

    state = InterviewState.analyzing;
    _notify();
    await _loadFeedback();
    _saveToFirestoreInBackground();
    state = InterviewState.finished;
    _notify();
  }

  // ─── RETRY after error ────────────────────────────────────────────────────
  Future<void> retryAfterError() async {
    state = InterviewState.userTurn;
    lastError = null;
    _notify();
  }

  // ─── AI SPEAK ─────────────────────────────────────────────────────────────
  Future<void> _aiSpeak(String text) async {
    state = InterviewState.aiSpeaking;
    messages.add(ChatMessage(isUser: false, text: text));
    _history.add({'role': 'assistant', 'content': text});
    _notify();

    try {
      final audioBase64 = await _service.textToSpeech(text);
      await _playAudio(audioBase64);
    } catch (e) {
      // TTS failure — fallback to delay (non-critical, don't show error)
      debugPrint('TTS error: $e');
      final ms = (text.length * 50).clamp(1000, 8000);
      await Future.delayed(Duration(milliseconds: ms));
    }

    if (state == InterviewState.aiSpeaking) {
      state = InterviewState.userTurn;
      _notify();
    }
  }

  // ─── AUDIO PLAYBACK ───────────────────────────────────────────────────────
  Future<void> _playAudio(String base64Audio) async {
    try {
      final bytes = base64Decode(base64Audio);
      final dir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/ai_speech_$ts.mp3');
      await file.writeAsBytes(bytes);

      await _player.stop();
      final duration = await _player.setFilePath(file.path);
      await _player.seek(Duration.zero);

      final completer = Completer<void>();
      final sub = _player.processingStateStream.listen((ps) {
        if (ps == ProcessingState.completed) {
          if (!completer.isCompleted) completer.complete();
        }
      });

      await _player.play();

      final timeout = (duration != null && duration.inMilliseconds > 0)
          ? duration + const Duration(milliseconds: 500)
          : const Duration(seconds: 30);

      await completer.future.timeout(timeout, onTimeout: () {
        debugPrint('Audio timeout after ${timeout.inSeconds}s');
      });

      await sub.cancel();
    } catch (e) {
      debugPrint('Audio play error: $e');
    }
  }

  // ─── RECORDING ────────────────────────────────────────────────────────────
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
    _notify();
  }

  Future<void> _stopRecordingAndProcess() async {
    await _recorder.stop();
    state = InterviewState.thinking;
    _notify();

    try {
      final audioBytes = await File(recordingPath!).readAsBytes();
      final audioBase64 = base64Encode(audioBytes);
      final transcript = await _service.transcribeAudio(
        audioBase64,
        languageCode: language.whisperCode,
      );

      if (transcript.trim().isEmpty) {
        state = InterviewState.userTurn;
        _notify();
        return;
      }

      messages.add(ChatMessage(isUser: true, text: transcript));
      _history.add({'role': 'user', 'content': transcript});
      _notify();

      await _getAiReply();
    } catch (e) {
      debugPrint('STT error: $e');
      lastError = e;
      state = InterviewState.error;
      _notify();
    }
  }

  // ─── TEXT MODE ────────────────────────────────────────────────────────────
  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    if (state == InterviewState.aiSpeaking || state == InterviewState.thinking) return;

    messages.add(ChatMessage(isUser: true, text: text));
    _history.add({'role': 'user', 'content': text});
    state = InterviewState.thinking;
    _notify();
    await _getAiReply();
  }

  // ─── GPT REPLY ────────────────────────────────────────────────────────────
  Future<void> _getAiReply() async {
    try {
      final result = await _service.interviewChat(
        messages: List.from(_history),
        jobRole: jobRole,
        jobDescription: jobDescription,
        interviewTypeHint: interviewType.systemPromptHint,
        languageInstruction: language.systemLanguageInstruction,
        levelHint: jobDescription != null ? '' : level.systemPromptHint,
        questionIndex: questionIndex,
        totalQuestions: totalQuestions,
      );

      final reply = result['reply'] as String? ?? '';
      questionIndex++;

      if (questionIndex >= totalQuestions) {
        await _aiSpeak(reply);
        state = InterviewState.analyzing;
        _notify();
        await _loadFeedback();
        _saveToFirestoreInBackground();
        state = InterviewState.finished;
        _notify();
      } else {
        await _aiSpeak(reply);
      }
    } catch (e) {
      debugPrint('GPT error: $e');
      lastError = e;
      state = InterviewState.error;
      _notify();
    }
  }

  // ─── FEEDBACK ─────────────────────────────────────────────────────────────
  Future<void> _loadFeedback() async {
    try {
      feedback = await _service.interviewFeedback(
        messages: List.from(_history),
        jobRole: jobRole,
        jobDescription: jobDescription,
        languageInstruction: language.systemLanguageInstruction,
        level: level.label,
      );
      _notify();
    } catch (e) {
      debugPrint('Feedback error: $e');
      lastError = e;
      feedback = {
        'overallScore': 0,
        'strengths': [],
        'improvements': [],
        'verdict': 'Maybe',
        'summary': 'Could not generate feedback.',
      };
      _notify();
    }
  }

  // ─── FIRESTORE ────────────────────────────────────────────────────────────
  void _saveToFirestoreInBackground() {
    _doSave().catchError((e) => debugPrint('Firestore bg error: $e'));
  }

  Future<void> _doSave() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || feedback == null) return;

    await FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('interviews').doc('last')
        .set({
      'jobRole':           jobRole,
      'level':             level.label,
      'score':             feedback!['overallScore'] ?? 0,
      'verdict':           feedback!['verdict']      ?? '',
      'summary':           feedback!['summary']      ?? '',
      'strengths':         List<String>.from(feedback!['strengths']    ?? []),
      'improvements':      List<String>.from(feedback!['improvements'] ?? []),
      'tips':              List<String>.from(feedback!['tips']         ?? []),
      'questionsAnswered': questionIndex,
      'totalQuestions':    totalQuestions,
      'usedJd':            jobDescription != null,
      'date':              FieldValue.serverTimestamp(),
    });
    debugPrint('✅ Saved to Firestore');
  }

  void _notify() { if (!_disposed) notifyListeners(); }

  void toggleTranscript() { showTranscript = !showTranscript; _notify(); }
  void toggleMode()        { voiceMode = !voiceMode; _notify(); }

  void restart() {
    state = InterviewState.idle;
    started = false;
    messages.clear();
    _history.clear();
    feedback = null;
    lastError = null;
    questionIndex = 0;
    jobDescription = null;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}