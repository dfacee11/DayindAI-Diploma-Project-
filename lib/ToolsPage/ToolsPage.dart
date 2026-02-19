import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    final tools = _allTools(context);

    final filteredTools = tools.where((tool) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return tool.title.toLowerCase().contains(q) ||
          tool.subtitle.toLowerCase().contains(q) ||
          tool.category.toLowerCase().contains(q);
    }).toList();

    // Group by category
    final aiTools =
        filteredTools.where((t) => t.category == "AI Tools").toList();
    final careerDocs =
        filteredTools.where((t) => t.category == "Career Docs").toList();
    final interviewPrep =
        filteredTools.where((t) => t.category == "Interview Prep").toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4), // чтобы не прилипало
              child: SizedBox(
                height: 73,
                width: 73,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/images/DayindAI1.png",
                    fit: BoxFit.cover,
                  ),
                ),
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
                          color: const Color(0xFF4C63FF),
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          const _DarkTopBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 110,
                        ),
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
                                "Tools",
                                style: GoogleFonts.montserrat(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Find the right tool for your career journey",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Search bar
                              _SearchBar(
                                controller: _searchController,
                                onChanged: (v) {
                                  setState(() => _query = v);
                                },
                              ),

                              const SizedBox(height: 22),

                              if (aiTools.isNotEmpty) ...[
                                _SectionTitle(title: "AI Tools"),
                                const SizedBox(height: 12),
                                _ToolGrid(tools: aiTools),
                                const SizedBox(height: 22),
                              ],

                              if (careerDocs.isNotEmpty) ...[
                                _SectionTitle(title: "Career Docs"),
                                const SizedBox(height: 12),
                                _ToolGrid(tools: careerDocs),
                                const SizedBox(height: 22),
                              ],

                              if (interviewPrep.isNotEmpty) ...[
                                _SectionTitle(title: "Interview Prep"),
                                const SizedBox(height: 12),
                                _ToolGrid(tools: interviewPrep),
                                const SizedBox(height: 22),
                              ],

                              if (filteredTools.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: Text(
                                      "No tools found 😅",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_ToolItem> _allTools(BuildContext context) {
    return [
      // AI Tools
      _ToolItem(
        category: "AI Tools",
        title: "AI Interview",
        subtitle: "Practice & feedback",
        icon: Icons.record_voice_over_rounded,
        onTap: () => Navigator.pushNamed(context, "/AIInterview"),
      ),
      _ToolItem(
        category: "AI Tools",
        title: "Resume Analyzer",
        subtitle: "AI resume review",
        icon: Icons.description_rounded,
        onTap: () => Navigator.pushNamed(context, "/AnalyzerResume"),
      ),
      _ToolItem(
        category: "AI Tools",
        title: "Resume Matching",
        subtitle: "Match resume to job",
        icon: Icons.compare_arrows_rounded,
        onTap: () => Navigator.pushNamed(context, "/ResumeMatching"),
      ),

      // Career Docs
      _ToolItem(
        category: "Career Docs",
        title: "Resume Templates",
        subtitle: "Ready CV designs",
        icon: Icons.grid_view_rounded,
        onTap: () {},
      ),
      _ToolItem(
        category: "Career Docs",
        title: "Cover Letter",
        subtitle: "Builder",
        icon: Icons.mail_outline_rounded,
        onTap: () {},
      ),

      // Interview Prep
      _ToolItem(
        category: "Interview Prep",
        title: "Question Bank",
        subtitle: "Common questions",
        icon: Icons.question_answer_rounded,
        onTap: () {},
      ),
      _ToolItem(
        category: "Interview Prep",
        title: "Roadmaps",
        subtitle: "Skills to learn",
        icon: Icons.route_rounded,
        onTap: () {},
      ),
    ];
  }
}

class _ToolItem {
  final String category;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _ToolItem({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class _ToolGrid extends StatelessWidget {
  final List<_ToolItem> tools;

  const _ToolGrid({required this.tools});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.05,
      children: tools
          .map(
            (t) => _FeatureTile(
              icon: t.icon,
              title: t.title,
              subtitle: t.subtitle,
              onTap: t.onTap,
            ),
          )
          .toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF0F172A),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
          ),
          hintText: "Search tools...",
          hintStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
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

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
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
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
