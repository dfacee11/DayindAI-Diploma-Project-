class ResumeMatchingResult {
  final int score;
  final String verdict;
  final List<String> matched;
  final List<String> missing;
  final List<String> tips;

  ResumeMatchingResult({
    required this.score,
    required this.verdict,
    required this.matched,
    required this.missing,
    required this.tips,
  });

  static List<String> _toStringList(dynamic val) {
    if (val == null) return [];
    return (val as List).map((e) => e.toString()).toList();
  }

  factory ResumeMatchingResult.fromJson(Map<String, dynamic> json) {
    return ResumeMatchingResult(
      score:   (json['score'] as num?)?.toInt() ?? 0,
      verdict: json['verdict']?.toString() ?? '',
      matched: _toStringList(json['matched']),
      missing: _toStringList(json['missing']),
      tips:    _toStringList(json['tips']),
    );
  }
}