import 'package:flutter/material.dart';
import 'dart:io';
import 'resume_upload_service.dart';
import 'resume_analysis_result.dart';

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
  ResumeAnalysisResult? result;

  final List<String> professions = [
    'Flutter Developer',
    'Backend Developer',
    'Frontend Developer',
    'QA Engineer',
  ];

  Future<void> analyzeResume() async {
    if (selectedProfession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите профессию')),
      );
      return;
    }

    if (selectedResumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Загрузите резюме')),
      );
      return;
    }

    setState(() {
      isAnalyzing = true;
      hasResult = false;
      result = null;
    });

    try {
      // ✅ ПОКА mock (можешь оставить)
      await Future.delayed(const Duration(seconds: 2));

      final mock = ResumeAnalysisResult(
        score: 7,
        strengths: [
          'Опыт работы с Flutter',
          'Знание REST API',
        ],
        weaknesses: [
          'Нет тестирования',
          'Слабое описание проектов',
        ],
        recommendations: [
          'Добавить информацию о проектах',
          'Указать достижения и метрики',
        ],
        levelMatch: {
          'Junior': 80,
          'Middle': 45,
          'Senior': 10,
        },
      );

      setState(() {
        isAnalyzing = false;
        hasResult = true;
        result = mock;
      });

      // ✅ ВОТ ТУТ будет backend позже:
      /*
      final json = await _uploadService.analyzeResume(
        file: selectedResumeFile!,
        profession: selectedProfession!,
      );

      setState(() {
        result = ResumeAnalysisResult.fromJson(json);
        isAnalyzing = false;
        hasResult = true;
      });
      */
    } catch (e) {
      setState(() {
        isAnalyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e")),
      );
    }
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

            // Upload resume
            GestureDetector(
<<<<<<< HEAD
              onTap: showUploadOptions,
=======
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: const Color(0xFF1E2038),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) {
                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.picture_as_pdf,
                                  color: Colors.white),
                              title: const Text(
                                "Upload File (PDF/TXT)",
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                final file =
                                    await _uploadService.pickResumeFile();
                                if (file != null) {
                                  setState(() => selectedResumeFile = file);
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library,
                                  color: Colors.white),
                              title: const Text(
                                "Choose Photo",
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                final file = await _uploadService
                                    .pickResumeImageFromGallery();
                                if (file != null) {
                                  setState(() => selectedResumeFile = file);
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                              title: const Text(
                                "Take Photo",
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                final file =
                                    await _uploadService.takeResumePhoto();
                                if (file != null) {
                                  setState(() => selectedResumeFile = file);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
>>>>>>> 7ba1829 (updated analyze page)
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2038),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.upload_file, color: Colors.white, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      selectedResumeFile == null
<<<<<<< HEAD
                          ? 'Загрузить резюме'
                          : 'Выбрано: ${selectedResumeFile!.path.split('/').last}',
=======
                          ? 'Загрузить резюме (PDF / TXT / PHOTO)'
                          : 'Файл выбран: ${selectedResumeFile!.path.split('/').last}',
>>>>>>> 7ba1829 (updated analyze page)
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

            if (hasResult && result != null) buildResult(),
          ],
        ),
      ),
    );
  }

  void showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2038),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.insert_drive_file, color: Colors.white),
                title: const Text(
                  'Загрузить файл (PDF / TXT)',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _uploadService.pickResumeFile();
                  if (file != null) {
                    setState(() {
                      selectedResumeFile = file;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.white),
                title: const Text(
                  'Загрузить из галереи',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _uploadService.pickResumeImage();
                  if (file != null) {
                    setState(() {
                      selectedResumeFile = file;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildResult() {
    final data = result!;

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
            'Score: ${data.score} / 10',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Уровень подготовки',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...data.levelMatch.entries.map((entry) {
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
          buildList('Сильные стороны', data.strengths),
          buildList('Слабые стороны', data.weaknesses),
          buildList('Рекомендации', data.recommendations),
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
