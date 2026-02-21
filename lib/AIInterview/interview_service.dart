import 'package:cloud_functions/cloud_functions.dart';

class InterviewService {
  final _functions = FirebaseFunctions.instance;

  Future<String> transcribeAudio(String audioBase64) async {
    final result = await _functions.httpsCallable('transcribeAudio').call({
      'audioBase64': audioBase64,
      'mimeType': 'audio/m4a',
    });
    return result.data['transcript'] as String? ?? '';
  }

  Future<Map<String, dynamic>> interviewChat({
    required List<Map<String, String>> messages,
    required String jobRole,
    required String interviewTypeHint,
    required int questionIndex,
    required int totalQuestions,
  }) async {
    final result = await _functions.httpsCallable('interviewChat').call({
      'messages': messages,
      'jobRole': jobRole,
      'interviewTypeHint': interviewTypeHint,
      'questionIndex': questionIndex,
      'totalQuestions': totalQuestions,
    });
    return Map<String, dynamic>.from(result.data);
  }

  Future<String> textToSpeech(String text) async {
    final result = await _functions.httpsCallable('textToSpeech').call({
      'text': text,
    });
    return result.data['audioBase64'] as String? ?? '';
  }

  Future<Map<String, dynamic>> interviewFeedback({
    required List<Map<String, String>> messages,
    required String jobRole,
  }) async {
    final result = await _functions.httpsCallable('interviewFeedback').call({
      'messages': messages,
      'jobRole': jobRole,
    });
    return Map<String, dynamic>.from(result.data);
  }
}