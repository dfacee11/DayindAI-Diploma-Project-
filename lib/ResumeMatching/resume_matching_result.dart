class ResumeMatchingResult {
  final int score;
  final String verdict;
  final int atsScore;
  final String experienceMatch;
  final List<String> matched;
  final List<String> missing;
  final List<String> topStrengths;
  final List<String> criticalGaps;
  final List<String> tips;

  ResumeMatchingResult({
    required this.score,
    required this.verdict,
    required this.atsScore,
    required this.experienceMatch,
    required this.matched,
    required this.missing,
    required this.topStrengths,
    required this.criticalGaps,
    required this.tips,
  });

  static List<String> _toStringList(dynamic val) {
    if (val == null) return [];
    return (val as List).map((e) => e.toString()).toList();
  }

  factory ResumeMatchingResult.fromJson(Map<String, dynamic> json) {
    return ResumeMatchingResult(
      score:           (json['score'] as num?)?.toInt() ?? 0,
      verdict:         json['verdict']?.toString() ?? '',
      atsScore:        (json['atsScore'] as num?)?.toInt() ?? 0,
      experienceMatch: json['experienceMatch']?.toString() ?? '',
      matched:         _toStringList(json['matched']),
      missing:         _toStringList(json['missing']),
      topStrengths:    _toStringList(json['topStrengths']),
      criticalGaps:    _toStringList(json['criticalGaps']),
      tips:            _toStringList(json['tips']),
    );
  }
}