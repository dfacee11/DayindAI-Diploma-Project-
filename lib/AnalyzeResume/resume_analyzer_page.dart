import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'resume_analyzer_provider.dart';

class ResumeAnalyzerPage extends StatelessWidget {
  const ResumeAnalyzerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResumeAnalyzerProvider(),
      child: const _ResumeAnalyzerView(),
    );
  }
}

class _ResumeAnalyzerView extends StatelessWidget {
  const _ResumeAnalyzerView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ResumeAnalyzerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121423),
      appBar: AppBar(
        title: const Text(
          'Resume Analyzer',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF121423),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload your resume and get AI analysis',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // Upload resume
            GestureDetector(
              onTap: () => _showUploadBottomSheet(context),
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
                      p.selectedResumeFile == null
                          ? 'Upload resume (PDF / TXT / PHOTO)'
                          : 'File selected: ${p.selectedResumeFile!.path.split('/').last}',
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
              value: p.selectedProfession,
              dropdownColor: const Color(0xFF1E2038),
              hint: const Text(
                "Choose profession",
                style: TextStyle(color: Colors.white54),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E2038),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              items: p.professions.map((job) {
                return DropdownMenuItem(
                  value: job,
                  child: Text(
                    job,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: p.setProfession,
            ),

            const SizedBox(height: 20),

            // Analyze button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: p.isAnalyzing ? null : () => p.analyze(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: p.isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Analyze Resume',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 30),

            if (p.result != null) _buildResult(p),
          ],
        ),
      ),
    );
  }

  void _showUploadBottomSheet(BuildContext context) {
    final p = context.read<ResumeAnalyzerProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2038),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.picture_as_pdf, color: Colors.white),
                  title: const Text(
                    "Upload File (PDF/TXT)",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await p.pickResumeFile();
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: Colors.white),
                  title: const Text(
                    "Choose Photo",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await p.pickFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.white),
                  title: const Text(
                    "Take Photo",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await p.takePhoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResult(ResumeAnalyzerProvider p) {
    final data = p.result!;

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
            'Level of preparation',
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
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.redAccent),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          _buildList('Strengths', data.strengths),
          _buildList('Weaknesses', data.weaknesses),
          _buildList('Recommendations', data.recommendations),
        ],
      ),
    );
  }

  Widget _buildList(String title, List<String> items) {
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