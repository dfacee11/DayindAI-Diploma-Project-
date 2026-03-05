import 'package:cloud_functions/cloud_functions.dart';

Map<String, dynamic> _deepCast(Map src) {
  return src.map((k, v) {
    if (v is Map) return MapEntry(k.toString(), _deepCast(v));
    if (v is List) return MapEntry(k.toString(), v.map((e) => e is Map ? _deepCast(e) : e).toList());
    return MapEntry(k.toString(), v);
  });
}

class ResumeMatchingService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> matchWithGpt({
    required String resumeText,
    required String jobDescription,
  }) async {
    final callable = _functions.httpsCallable('matchResume');
    final res = await callable.call({'resumeText': resumeText, 'jobText': jobDescription});
    return _deepCast(res.data as Map);
  }
}