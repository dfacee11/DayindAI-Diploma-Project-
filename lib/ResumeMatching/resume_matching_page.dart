import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          "Resume Matching",
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
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
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
                          Text(
                            "Match your resume",
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Upload resume + paste job description.",
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ✅ Upload resume card
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
                                        borderRadius: BorderRadius.circular(18),
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

                          const SizedBox(height: 18),

                          // ✅ Job description
                          _WhiteCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Job Description",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    maxLines: 7,
                                    onChanged: p.setJobDescription,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Paste job description ",
                                      hintStyle: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ✅ Match button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed:
                                  p.isMatching ? null : () => p.match(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7C5CFF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: p.isMatching
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      "Match Now",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          if (p.result != null)
                            _ResultSection(result: p.result!),
                        ],
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
    final p = context.read<ResumeMatchingProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
}

class _ResultSection extends StatelessWidget {
  final ResumeMatchingResult result;

  const _ResultSection({required this.result});

  @override
  Widget build(BuildContext context) {
    final score = result.score;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WhiteCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Match Score",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: score / 100,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF7C5CFF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "$score%",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _KeywordBlock(
          title: "Matched keywords",
          items: result.matched,
          good: true,
        ),
        const SizedBox(height: 12),
        _KeywordBlock(
          title: "Missing keywords",
          items: result.missing,
          good: false,
        ),
        const SizedBox(height: 14),
        _WhiteCard(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tips",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                ...result.tips.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "• $t",
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
            ),
          ),
        ),
      ],
    );
  }
}

class _KeywordBlock extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool good;

  const _KeywordBlock({
    required this.title,
    required this.items,
    required this.good,
  });

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items.isEmpty
                  ? [
                      Text(
                        "No data yet.",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ]
                  : items.map((e) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: good
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: good
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFFFED7AA),
                          ),
                        ),
                        child: Text(
                          e,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: good
                                ? const Color(0xFF14532D)
                                : const Color(0xFF9A3412),
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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
