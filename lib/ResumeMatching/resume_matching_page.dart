import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dayindai/HomePage/widgets/dark_background.dart';
import 'package:dayindai/AnalyzeResume/widgets/white_card.dart';
import 'package:dayindai/AnalyzeResume/widgets/bottom_sheet_tile.dart';
import 'resume_matching_provider.dart';
import 'resume_matching_result.dart';

class ResumeMatchingPage extends StatelessWidget {
  const ResumeMatchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResumeMatchingProvider(),
      child: const _ResumeMatchingView(),
    );
  }
}

class _ResumeMatchingView extends StatelessWidget {
  const _ResumeMatchingView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ResumeMatchingProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text("Resume Matching",
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
      body: Stack(
        children: [
          const DarkTopBackground(),
          Positioned(top: 200, left: 0, right: 0, bottom: 0, child: Container(color: const Color(0xFFF4F5FA))),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F5FA),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(34), topRight: Radius.circular(34)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Match your resume",
                            style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                        const SizedBox(height: 6),
                        Text("Upload resume + paste job description.",
                            style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                        const SizedBox(height: 18),
                        _buildUploadCard(context, p),
                        const SizedBox(height: 18),
                        _buildJobDescriptionField(p),
                        const SizedBox(height: 18),
                        _buildMatchButton(context, p),
                        const SizedBox(height: 18),
                        if (p.result != null) _buildResult(p.result!),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context, ResumeMatchingProvider p) {
    final ext = p.selectedResumeFile?.path.split('.').last.toLowerCase();
    final isPdf = ext == 'pdf';
    final isImage = ext == 'jpg' || ext == 'jpeg' || ext == 'png';

    return WhiteCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _showUploadBottomSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPdf
                        ? [const Color(0xFFEF4444), const Color(0xFFF97316)]
                        : isImage
                            ? [const Color(0xFF10B981), const Color(0xFF06B6D4)]
                            : [const Color(0xFF7C5CFF), const Color(0xFF2DD4FF)],
                  ),
                ),
                child: Icon(
                  isPdf ? Icons.picture_as_pdf_rounded : isImage ? Icons.image_rounded : Icons.upload_file_rounded,
                  color: Colors.white, size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.selectedResumeFile == null ? "Upload resume" : "File selected",
                      style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.selectedResumeFile == null ? "PDF or Photo" : p.selectedResumeFile!.path.split('/').last,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobDescriptionField(ResumeMatchingProvider p) {
    return WhiteCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Job Description",
                style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
            const SizedBox(height: 10),
            TextField(
              maxLines: 7,
              onChanged: p.setJobDescription,
              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: "Paste job description here...",
                hintStyle: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchButton(BuildContext context, ResumeMatchingProvider p) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: p.isMatching ? null : () => p.match(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF06B6D4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: p.isMatching
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Text("Match Now", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900)),
      ),
    );
  }

  void _showUploadBottomSheet(BuildContext context) {
    final p = context.read<ResumeMatchingProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
                Container(width: 44, height: 5,
                    decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(100))),
                const SizedBox(height: 14),
                BottomSheetTile(icon: Icons.picture_as_pdf_rounded, title: "Upload PDF",
                    onTap: () async { Navigator.pop(context); await p.pickResumeFile(); }),
                BottomSheetTile(icon: Icons.photo_library_rounded, title: "Choose Photo from Gallery",
                    onTap: () async { Navigator.pop(context); await p.pickFromGallery(); }),
                BottomSheetTile(icon: Icons.camera_alt_rounded, title: "Take Photo",
                    onTap: () async { Navigator.pop(context); await p.takePhoto(); }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(ResumeMatchingResult data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Match Result",
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        const SizedBox(height: 14),

        // ── Score + Verdict ───────────────────────────────────────────────
        WhiteCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildScoreCircle(data.score),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBadge(data.verdict, _verdictColor(data.verdict)),
                      const SizedBox(height: 8),
                      _buildBadge('Experience: ${data.experienceMatch}', _expColor(data.experienceMatch)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.fact_check_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text("ATS Score: ${data.atsScore}%",
                              style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: data.atsScore / 100,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation(_atsColor(data.atsScore)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ── Keywords ──────────────────────────────────────────────────────
        WhiteCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Matched Keywords",
                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: data.matched.map((s) => _buildChip(s, const Color(0xFF22C55E))).toList(),
                ),
                if (data.missing.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text("Missing Keywords",
                      style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: data.missing.map((s) => _buildChip(s, const Color(0xFFEF4444))).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ── Strengths + Gaps + Tips ───────────────────────────────────────
        WhiteCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildList("💪 Top Strengths",  data.topStrengths, const Color(0xFF22C55E)),
                _buildList("🚨 Critical Gaps",  data.criticalGaps, const Color(0xFFEF4444)),
                _buildList("💡 Tips",           data.tips,         const Color(0xFF7C5CFF)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCircle(int score) {
    final color = score >= 75 ? const Color(0xFF22C55E) : score >= 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$score', style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
          Text('%', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildList(String title, List<String> items, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(title, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6, height: 6,
                margin: const EdgeInsets.only(top: 5, right: 8),
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              Expanded(
                child: Text(item,
                    style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B), height: 1.3)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Color _verdictColor(String v) {
    if (v == 'Strong Match') return const Color(0xFF22C55E);
    if (v == 'Good Match') return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _expColor(String v) {
    if (v == 'Exceeds') return const Color(0xFF22C55E);
    if (v == 'Meets') return const Color(0xFF3B82F6);
    return const Color(0xFFF59E0B);
  }

  Color _atsColor(int score) {
    if (score >= 70) return const Color(0xFF22C55E);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}