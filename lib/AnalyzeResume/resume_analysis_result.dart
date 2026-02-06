class ResumeAnalysisResult {
  final int score;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final Map<String, int> levelMatch;

  ResumeAnalysisResult({
    required this.score,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.levelMatch,
  });

  factory ResumeAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ResumeAnalysisResult(
      score: json['score'] ?? 0,
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      levelMatch: Map<String, int>.from(json['levelMatch'] ?? {}),
    );
  }
}