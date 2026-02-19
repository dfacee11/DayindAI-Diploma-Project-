import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          "Resume Analyzer",
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          const _DarkTopBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F5FA),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(34),
                          topRight: Radius.circular(34),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Upload your resume",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Get AI analysis, strengths, weaknesses and tips.",
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Upload card
                            _WhiteCard(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () => _showUploadBottomSheet(context),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF7C5CFF),
                                              Color(0xFF2DD4FF),
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.upload_file_rounded,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.selectedResumeFile == null
                                                  ? "Upload resume"
                                                  : "File selected",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              p.selectedResumeFile == null
                                                  ? "PDF / TXT / PHOTO"
                                                  : p.selectedResumeFile!.path
                                                      .split('/')
                                                      .last,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Profession dropdown
                            Text(
                              "Choose profession",
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),

                            _WhiteCard(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: p.selectedProfession,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF64748B),
                                  ),
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xFF0F172A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  hint: Text(
                                    "Select profession",
                                    style: GoogleFonts.montserrat(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  items: p.professions.map((job) {
                                    return DropdownMenuItem(
                                      value: job,
                                      child: Text(job),
                                    );
                                  }).toList(),
                                  onChanged: p.setProfession,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Analyze button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: p.isAnalyzing
                                    ? null
                                    : () => p.analyze(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C5CFF),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: p.isAnalyzing
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Analyze Resume",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            if (p.result != null) _buildResult(p),

                            // This spacer forces the white container to fill the screen
                            const SizedBox(
                              height: 14,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadBottomSheet(BuildContext context) {
    final p = context.read<ResumeAnalyzerProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF4F5FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _BottomSheetTile(
                    icon: Icons.picture_as_pdf_rounded,
                    title: "Upload File (PDF/TXT)",
                    onTap: () async {
                      Navigator.pop(context);
                      await p.pickResumeFile();
                    },
                  ),
                  _BottomSheetTile(
                    icon: Icons.photo_library_rounded,
                    title: "Choose Photo",
                    onTap: () async {
                      Navigator.pop(context);
                      await p.pickFromGallery();
                    },
                  ),
                  _BottomSheetTile(
                    icon: Icons.camera_alt_rounded,
                    title: "Take Photo",
                    onTap: () async {
                      Navigator.pop(context);
                      await p.takePhoto();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResult(ResumeAnalyzerProvider p) {
    final data = p.result!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Result",
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        _WhiteCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF7C5CFF),
                            Color(0xFF2DD4FF),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Resume score",
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "AI evaluation",
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${data.score} / 10",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Level of preparation",
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                ...data.levelMatch.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${entry.key} — ${entry.value}%",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: entry.value / 100,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF7C5CFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                _buildList("Strengths", data.strengths),
                _buildList("Weaknesses", data.weaknesses),
                _buildList("Recommendations", data.recommendations),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              "• $item",
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
                height: 1.25,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ================== UI HELPERS ================== */

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BottomSheetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _BottomSheetTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7C5CFF),
                      Color(0xFF2DD4FF),
                    ],
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================== BACKGROUND ================== */

class _DarkTopBackground extends StatelessWidget {
  const _DarkTopBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B1220),
            Color(0xFF121A2B),
            Color(0xFF1A2236),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -90,
            child: _BlurBlob(
              size: 300,
              color: const Color(0xFF7C5CFF).withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            top: 120,
            right: -130,
            child: _BlurBlob(
              size: 340,
              color: const Color(0xFF2DD4FF).withValues(alpha: 0.18),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurBlob({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
