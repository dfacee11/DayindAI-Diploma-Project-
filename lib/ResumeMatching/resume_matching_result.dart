class ResumeMatchingResult {
  final int score; // 0..100
  final List<String> matched;
  final List<String> missing;
  final List<String> tips;

  ResumeMatchingResult({
    required this.score,
    required this.matched,
    required this.missing,
    required this.tips,
  });

  factory ResumeMatchingResult.fromJson(Map<String, dynamic> json) {
    return ResumeMatchingResult(
      score: (json["score"] ?? 0) as int,
      matched: List<String>.from(json["matched"] ?? []),
      missing: List<String>.from(json["missing"] ?? []),
      tips: List<String>.from(json["tips"] ?? []),
    );
  }
}