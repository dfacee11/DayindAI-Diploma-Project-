import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dayindai/HomePage/widgets/dark_background.dart';
import 'package:dayindai/AnalyzeResume/widgets/white_card.dart';
import 'package:dayindai/AnalyzeResume/widgets/bottom_sheet_tile.dart';
import 'resume_matching_provider.dart';
import ' widgets/result_section.dart';

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          "Resume Matching",
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          const DarkTopBackground(),
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
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(34),
                        topRight: Radius.circular(34),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Match your resume", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                        const SizedBox(height: 6),
                        Text("Upload resume + paste job description.", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                        const SizedBox(height: 18),
                        _buildUploadCard(context, p),
                        const SizedBox(height: 18),
                        _buildJobDescriptionField(p),
                        const SizedBox(height: 18),
                        _buildMatchButton(context, p),
                        const SizedBox(height: 18),
                        if (p.result != null) ResultSection(result: p.result!),
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
    return WhiteCard(
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
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)],
                  ),
                ),
                child: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 26),
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
                      p.selectedResumeFile == null ? "PDF / TXT / PHOTO" : p.selectedResumeFile!.path.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            Text("Job Description", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
            const SizedBox(height: 10),
            TextField(
              maxLines: 7,
              onChanged: p.setJobDescription,
              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: "Paste job description",
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
          backgroundColor: const Color(0xFF7C5CFF),
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
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(100)),
                ),
                const SizedBox(height: 14),
                BottomSheetTile(icon: Icons.picture_as_pdf_rounded, title: "Upload File (PDF/TXT)", onTap: () async { Navigator.pop(context); await p.pickResumeFile(); }),
                BottomSheetTile(icon: Icons.photo_library_rounded,   title: "Choose Photo",         onTap: () async { Navigator.pop(context); await p.pickFromGallery(); }),
                BottomSheetTile(icon: Icons.camera_alt_rounded,      title: "Take Photo",           onTap: () async { Navigator.pop(context); await p.takePhoto(); }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
