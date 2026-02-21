import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum InterviewType { behavioral, technical, mixed }

extension InterviewTypeExt on InterviewType {
  String get label {
    switch (this) {
      case InterviewType.behavioral: return "About Yourself";
      case InterviewType.technical:  return "Technical";
      case InterviewType.mixed:      return "Mixed";
    }
  }

  String get description {
    switch (this) {
      case InterviewType.behavioral: return "Background, strengths, experience, goals";
      case InterviewType.technical:  return "Coding, system design, technical skills";
      case InterviewType.mixed:      return "Both behavioral & technical questions";
    }
  }

  IconData get icon {
    switch (this) {
      case InterviewType.behavioral: return Icons.person_rounded;
      case InterviewType.technical:  return Icons.code_rounded;
      case InterviewType.mixed:      return Icons.shuffle_rounded;
    }
  }

  String get systemPromptHint {
    switch (this) {
      case InterviewType.behavioral:
        return "Focus ONLY on behavioral questions: background, strengths, weaknesses, motivation, teamwork, leadership, career goals.";
      case InterviewType.technical:
        return "Focus ONLY on technical questions: coding problems, system design, algorithms, architecture, tools relevant to the role.";
      case InterviewType.mixed:
        return "Mix of behavioral and technical questions. Start with background, then move to technical skills.";
    }
  }
}

class IntroUI extends StatefulWidget {
  final void Function(String jobRole, InterviewType type, int questionCount) onStart;

  const IntroUI({super.key, required this.onStart});

  @override
  State<IntroUI> createState() => _IntroUIState();
}

class _IntroUIState extends State<IntroUI> {
  final _roleController = TextEditingController(text: 'Software Engineer');
  InterviewType _selectedType = InterviewType.mixed;
  int _questionCount = 7;

  final List<String> _presets = [
    'Software Engineer', 'Product Manager', 'Data Scientist',
    'UX Designer', 'Marketing Manager', 'DevOps Engineer',
  ];

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(),
            const SizedBox(height: 16),
            Text("AI Interview", style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 6),
            Text(
              "Customize your interview session below",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.60)),
            ),
            const SizedBox(height: 22),

            // Job role input
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _roleController,
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Job role...',
                  hintStyle: GoogleFonts.montserrat(color: Colors.white.withValues(alpha: 0.4)),
                  prefixIcon: Icon(Icons.work_outline_rounded, color: Colors.white.withValues(alpha: 0.6), size: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Role presets
            Wrap(
              spacing: 8, runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _presets.map((role) => GestureDetector(
                onTap: () => setState(() => _roleController.text = role),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Text(role, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.85))),
                ),
              )).toList(),
            ),

            const SizedBox(height: 20),

            // Interview type
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Interview Type", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.7))),
            ),
            const SizedBox(height: 10),
            ...InterviewType.values.map((type) => GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == type ? const Color(0xFF7C5CFF).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _selectedType == type ? const Color(0xFF7C5CFF) : Colors.white.withValues(alpha: 0.12),
                    width: _selectedType == type ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(type.icon, color: _selectedType == type ? Colors.white : Colors.white.withValues(alpha: 0.5), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(type.label, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text(type.description, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.55))),
                        ],
                      ),
                    ),
                    if (_selectedType == type)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF7C5CFF), size: 20),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 16),

            // Question count
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Number of Questions", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.7))),
            ),
            const SizedBox(height: 10),
            Row(
              children: [5, 7, 10].map((count) {
                final isLast = count == 10;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _questionCount = count),
                    child: Container(
                      margin: EdgeInsets.only(right: isLast ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _questionCount == count ? const Color(0xFF7C5CFF).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _questionCount == count ? const Color(0xFF7C5CFF) : Colors.white.withValues(alpha: 0.12),
                          width: _questionCount == count ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('$count', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                          Text('questions', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55))),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final role = _roleController.text.trim();
                  if (role.isEmpty) return;
                  widget.onStart(role, _selectedType, _questionCount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C5CFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text("Start Interview", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 130, height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0.04)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Center(
            child: Image.asset("assets/images/aipenguin.png", width: 100, height: 100, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}