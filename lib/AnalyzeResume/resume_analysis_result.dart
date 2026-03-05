class ResumeAnalysisResult {
  final int score;
  final String verdict;
  final String experienceLevel;
  final int atsScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final List<String> keySkillsFound;
  final List<String> missingSkills;
  final Map<String, int> levelMatch;

  ResumeAnalysisResult({
    required this.score,
    required this.verdict,
    required this.experienceLevel,
    required this.atsScore,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.keySkillsFound,
    required this.missingSkills,
    required this.levelMatch,
  });

  static List<String> _toStringList(dynamic val) {
    if (val == null) return [];
    return (val as List).map((e) => e.toString()).toList();
  }

  static Map<String, int> _toStringIntMap(dynamic val) {
    if (val == null) return {};
    return (val as Map).map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
  }

  factory ResumeAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ResumeAnalysisResult(
      score:           (json['score'] as num?)?.toInt() ?? 0,
      verdict:         json['verdict']?.toString() ?? '',
      experienceLevel: json['experienceLevel']?.toString() ?? '',
      atsScore:        (json['atsScore'] as num?)?.toInt() ?? 0,
      strengths:       _toStringList(json['strengths']),
      weaknesses:      _toStringList(json['weaknesses']),
      recommendations: _toStringList(json['recommendations']),
      keySkillsFound:  _toStringList(json['keySkillsFound']),
      missingSkills:   _toStringList(json['missingSkills']),
      levelMatch:      _toStringIntMap(json['levelMatch']),
    );
  }
}