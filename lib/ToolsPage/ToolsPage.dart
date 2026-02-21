import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dayindai/HomePage/widgets/dark_background.dart';
import 'models/tool_item.dart';
import 'widgets/tools_search_bar.dart';
import 'widgets/tools_section.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ToolItem> _allTools() {
    return [
      ToolItem(
          category: "AI Tools",
          title: "AI Interview",
          subtitle: "Practice interviews & get feedback",
          icon: Icons.record_voice_over_rounded,
          onTap: () => Navigator.pushNamed(context, "/AIInterview")),
      ToolItem(
          category: "AI Tools",
          title: "Resume Analyzer",
          subtitle: "AI-powered resume review",
          icon: Icons.description_rounded,
          onTap: () => Navigator.pushNamed(context, "/AnalyzerResume")),
      ToolItem(
          category: "AI Tools",
          title: "Resume Matching",
          subtitle: "Match your resume to a job",
          icon: Icons.compare_arrows_rounded,
          onTap: () => Navigator.pushNamed(context, "/ResumeMatching")),
      ToolItem(
          category: "Career Docs",
          title: "Resume Templates",
          subtitle: "Ready-to-use CV designs",
          icon: Icons.grid_view_rounded,
          onTap: () {}),
      ToolItem(
          category: "Career Docs",
          title: "Cover Letter",
          subtitle: "AI cover letter builder",
          icon: Icons.mail_outline_rounded,
          onTap: () {}),
      ToolItem(
          category: "Interview Prep",
          title: "Question Bank",
          subtitle: "Common interview questions",
          icon: Icons.question_answer_rounded,
          onTap: () {}),
      ToolItem(
          category: "Interview Prep",
          title: "Roadmaps",
          subtitle: "Skills & learning paths",
          icon: Icons.route_rounded,
          onTap: () {}),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final all = _allTools();

    final filtered = all.where((t) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return t.title.toLowerCase().contains(q) ||
          t.subtitle.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
    }).toList();

    final aiTools = filtered.where((t) => t.category == "AI Tools").toList();
    final careerDocs =
        filtered.where((t) => t.category == "Career Docs").toList();
    final interviewPrep =
        filtered.where((t) => t.category == "Interview Prep").toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            SizedBox(
              height: 73,
              width: 73,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset("assets/images/DayindAI1.png",
                    fit: BoxFit.cover),
              ),
            ),
            RichText(
              text: TextSpan(
                text: "Dayind",
                style: GoogleFonts.montserrat(
                    fontSize: 27,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: "AI",
                    style: GoogleFonts.montserrat(
                        fontSize: 27,
                        color: const Color(0xFF7C5CFF),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          const DarkTopBackground(),
          Positioned(
              top: 200,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(color: const Color(0xFFF4F5FA))),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 110),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F5FA),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(34),
                            topRight: Radius.circular(34)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tools",
                                style: GoogleFonts.montserrat(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            Text("Find the right tool for your career journey",
                                style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B))),
                            const SizedBox(height: 18),
                            ToolsSearchBar(
                                controller: _searchController,
                                onChanged: (v) => setState(() => _query = v)),
                            const SizedBox(height: 24),
                            if (filtered.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Column(
                                    children: [
                                      const Text("🐧",
                                          style: TextStyle(fontSize: 48)),
                                      const SizedBox(height: 12),
                                      Text("No tools found",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                              ),
                            if (aiTools.isNotEmpty) ...[
                              ToolsSection(title: "AI Tools", tools: aiTools),
                              const SizedBox(height: 24),
                            ],
                            if (careerDocs.isNotEmpty) ...[
                              ToolsSection(
                                  title: "Career Docs", tools: careerDocs),
                              const SizedBox(height: 24),
                            ],
                            if (interviewPrep.isNotEmpty) ...[
                              ToolsSection(
                                  title: "Interview Prep",
                                  tools: interviewPrep),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
