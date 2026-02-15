import 'package:cloud_functions/cloud_functions.dart';

class ResumeMatchingService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> matchWithDeepseek({
    required String resumeText,
    required String jobDescription,
  }) async {
    final callable = _functions.httpsCallable("matchResumeDeepseek");

    final res = await callable.call({
      "resumeText": resumeText,
      "jobText": jobDescription, // 🔥 в Firebase мы отправляем jobText
    });

    return Map<String, dynamic>.from(res.data);
  }
}