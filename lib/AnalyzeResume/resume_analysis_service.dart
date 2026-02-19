import 'package:cloud_functions/cloud_functions.dart';

class ResumeAnalysisService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> analyzeWithDeepseek({
    required String text,
    required String profession,
  }) async {
    final callable = _functions.httpsCallable("analyzeResumeDeepseek");
    final res = await callable.call({"text": text, "profession": profession});
    return Map<String, dynamic>.from(res.data);
  }
}