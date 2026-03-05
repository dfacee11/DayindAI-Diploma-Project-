import 'package:cloud_functions/cloud_functions.dart';

Map<String, dynamic> _deepCast(Map src) {
  return src.map((k, v) {
    if (v is Map) return MapEntry(k.toString(), _deepCast(v));
    if (v is List) return MapEntry(k.toString(), v.map((e) => e is Map ? _deepCast(e) : e).toList());
    return MapEntry(k.toString(), v);
  });
}

class ResumeAnalysisService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> analyzeWithGpt({
    required String text,
    required String profession,
  }) async {
    final callable = _functions.httpsCallable('analyzeResume');
    final res = await callable.call({'text': text, 'profession': profession});
    return _deepCast(res.data as Map);
  }
}