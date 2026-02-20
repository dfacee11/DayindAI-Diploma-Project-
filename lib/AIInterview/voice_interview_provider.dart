import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'models/chat_message.dart';
import 'interview_service.dart';

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
  // для GPT-4o — история в формате {role, content}
  final List<Map<String, String>> _history = [];

  String jobRole = "Software Engineer";
  int questionIndex = 0;
  static const int totalQuestions = 7;

  Map<String, dynamic>? feedback;
  String? recordingPath;

  bool get isAiSpeaking  => state == InterviewState.aiSpeaking;
  bool get isThinking    => state == InterviewState.thinking;
  bool get isRecording   => state == InterviewState.recording;
  bool get isFinished    => state == InterviewState.finished;

  String get statusText {
    switch (state) {
      case InterviewState.aiSpeaking:  return "AI is speaking...";
      case InterviewState.thinking:    return "AI is thinking...";
      case InterviewState.recording:   return "Listening...";
      case InterviewState.finished:    return "Interview complete!";
      default:                         return "Your turn — tap mic to speak";
    }
  }

  // ───────────── START ─────────────
  Future<void> startInterview(String role) async {
    jobRole = role;
    started = true;
    questionIndex = 0;
    messages.clear();
    _history.clear();
    feedback = null;
    notifyListeners();

    const opening = "Hello! Welcome to your interview. Let's start — could you tell me a little about yourself?";
    await _aiSpeak(opening);
  }

  // ───────────── AI говорит ─────────────
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
      // fallback: просто подождём как раньше
      await Future.delayed(Duration(milliseconds: 800 + text.length * 12));
    }

    state = InterviewState.userTurn;
    notifyListeners();
  }

  // ───────────── ВОСПРОИЗВЕДЕНИЕ ─────────────
  Future<void> _playAudio(String base64) async {
    try {
      final bytes = base64Decode(base64);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ai_speech.mp3');
      await file.writeAsBytes(bytes);
      await _player.setFilePath(file.path);
      await _player.play();
      await _player.processingStateStream
          .firstWhere((s) => s == ProcessingState.completed);
    } catch (e) {
      debugPrint('Audio play error: $e');
    }
  }

  // ───────────── ЗАПИСЬ ─────────────
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
      RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
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
      // STT
      final audioBytes = await File(recordingPath!).readAsBytes();
      final audioBase64 = base64Encode(audioBytes);
      final transcript = await _service.transcribeAudio(audioBase64);

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

  // ───────────── TEXT MODE ─────────────
  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    if (state == InterviewState.aiSpeaking || state == InterviewState.thinking) return;

    messages.add(ChatMessage(isUser: true, text: text));
    _history.add({'role': 'user', 'content': text});
    state = InterviewState.thinking;
    notifyListeners();

    await _getAiReply();
  }

  // ───────────── GPT-4o ОТВЕТ ─────────────
  Future<void> _getAiReply() async {
    try {
      final result = await _service.interviewChat(
        messages: List.from(_history),
        jobRole: jobRole,
        questionIndex: questionIndex,
        totalQuestions: totalQuestions,
      );

      final reply = result['reply'] as String? ?? '';
      final isFinished = result['isFinished'] as bool? ?? false;

      questionIndex++;

      if (isFinished || questionIndex >= totalQuestions) {
        await _aiSpeak(reply);
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

  // ───────────── FEEDBACK ─────────────
  Future<void> _loadFeedback() async {
    try {
      feedback = await _service.interviewFeedback(
        messages: List.from(_history),
        jobRole: jobRole,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Feedback error: $e');
    }
  }

  // ───────────── UI HELPERS ─────────────
  void toggleTranscript() {
    showTranscript = !showTranscript;
    notifyListeners();
  }

  void toggleMode() {
    voiceMode = !voiceMode;
    notifyListeners();
  }

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