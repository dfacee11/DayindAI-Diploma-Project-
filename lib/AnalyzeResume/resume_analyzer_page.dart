import 'package:flutter/material.dart';
import 'dart:io';
import 'resume_upload_service.dart';

class ResumeAnalyzerPage extends StatefulWidget {
  const ResumeAnalyzerPage({super.key});

  @override
  State<ResumeAnalyzerPage> createState() => _ResumeAnalyzerPageState();
}

class _ResumeAnalyzerPageState extends State<ResumeAnalyzerPage> {
  String? selectedProfession;
  bool isAnalyzing = false;
  bool hasResult = false;
  final ResumeUploadService _uploadService = ResumeUploadService();
  File? selectedResumeFile;
  // mock result
  int score = 7;
  List<String> strengths = [
    'Опыт работы с Flutter',
    'Знание REST API',
  ];
  List<String> weaknesses = [
    'Нет тестирования',
    'Слабое описание проектов',
  ];
  List<String> recommendations = [
    'Добавить информацию о проектах',
    'Указать достижения и метрики',
  ];

  final List<String> professions = [
    'Flutter Developer',
    'Backend Developer',
    'Frontend Developer',
    'QA Engineer',
  ];

  Map<String, int> levelMatch = {
    'Junior': 80,
    'Middle': 45,
    'Senior': 10,
  };

  Future<void> analyzeResume() async {
    if (selectedProfession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите профессию')),
      );
      return;
    }

    setState(() {
      isAnalyzing = true;
      hasResult = false;
    });

    // ⏳ имитация AI-анализа
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isAnalyzing = false;
      hasResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121423),
      appBar: AppBar(
        title: const Text(
          'Resume Analyzer',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF121423),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Загрузите резюме и получите AI-анализ',
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            // Upload resume (пока заглушка)
            GestureDetector(
              onTap: () async {
                final file = await _uploadService.pickResumeFile();
                if (file != null) {
                  setState(() {
                    selectedResumeFile = file;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2038),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.upload_file,
                        color: Colors.white, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      selectedResumeFile == null
                          ? 'Загрузить резюме (PDF / TXT)'
                          : 'Файл выбран: ${selectedResumeFile!.path.split('/').last}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Profession dropdown
            DropdownButtonFormField<String>(
              value: selectedProfession,
              dropdownColor: const Color(0xFF1E2038),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E2038),
                hintText: 'Выберите профессию',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              items: professions
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedProfession = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Analyze button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isAnalyzing ? null : analyzeResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Analyze Resume'),
              ),
            ),

            const SizedBox(height: 30),

            if (hasResult) buildResult(),
          ],
        ),
      ),
    );
  }

  Widget buildResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2038),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score: $score / 10',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 LEVEL MATCH SECTION
          const Text(
            'Уровень подготовки',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...levelMatch.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key} — ${entry.value}%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / 100,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Colors.redAccent),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          buildList('Сильные стороны', strengths),
          buildList('Слабые стороны', weaknesses),
          buildList('Рекомендации', recommendations),
        ],
      ),
    );
  }

  Widget buildList(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Text(
            '• $item',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
