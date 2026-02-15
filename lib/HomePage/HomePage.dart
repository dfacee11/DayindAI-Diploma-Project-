import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;

  final PageController _toolController = PageController(viewportFraction: 1);
  int _toolIndex = 0;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    FirebaseAuth.instance.userChanges().listen((u) {
      if (mounted) setState(() => _user = u);
    });

    _toolController.addListener(() {
      final page = _toolController.page ?? 0;
      final newIndex = page.round();
      if (newIndex != _toolIndex) {
        setState(() => _toolIndex = newIndex);
      }
    });
  }

  @override
  void dispose() {
    _toolController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/FirstPage');
  }

  void _nextTool() {
    if (_toolIndex < 2) {
      _toolController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  void _prevTool() {
    if (_toolIndex > 0) {
      _toolController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName ?? 'User';

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
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _signOut,
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

                      // Белая часть - полностью на весь экран
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
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Hi ",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    TextSpan(
                                      text: "$displayName,",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(
                                            0xFF4C63FF), // цвет имени
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Choose an AI tool to continue",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 22),
                              Text(
                                "AI Tools",
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 185,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    // ⭐ card width limited
                                    Center(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(26),
                                          child: PageView(
                                            controller: _toolController,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            children: [
                                              _AiToolCard(
                                                title: "AI Interview",
                                                description:
                                                    "Practice interview with AI + get feedback.",
                                                icon: Icons
                                                    .record_voice_over_rounded,
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF7C5CFF),
                                                    Color(0xFF2DD4FF),
                                                  ],
                                                ),
                                                buttonText: "Start Interview",
                                                imagePath: "assets/images/pin1.png",
                                                onTap: () =>
                                                    Navigator.pushNamed(context,
                                                        "/AIInterview"),
                                              ),
                                              _AiToolCard(
                                                title: "Resume Analyzer",
                                                description:
                                                    "Upload resume and get AI review + tips.",
                                                icon: Icons.description_rounded,
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF4F46E5),
                                                    Color(0xFF38BDF8),
                                                  ],
                                                ),
                                                buttonText: "Analyze Resume",
                                                imagePath: "assets/images/pin2.png",
                                                onTap: () =>
                                                    Navigator.pushNamed(context,
                                                        "/AnalyzerResume"),
                                              ),
                                              _AiToolCard(
                                                title: "Resume Matching",
                                                description:
                                                    "Check how well your resume matches a job.",
                                                icon: Icons
                                                    .compare_arrows_rounded,
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF9333EA),
                                                    Color(0xFF60A5FA),
                                                  ],
                                                ),
                                                buttonText: "Match Now",
                                                imagePath: "assets/images/pin3.png",
                                                onTap: () =>
                                                    Navigator.pushNamed(context,
                                                        "/ResumeMatching"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ⬅️ arrow left
                                    Positioned(
                                      left: -18,
                                      child: _ArrowOverlayButton(
                                        icon: Icons.chevron_left_rounded,
                                        onTap: _prevTool,
                                        enabled: _toolIndex > 0,
                                      ),
                                    ),

                                    // ➡️ arrow right
                                    Positioned(
                                      right: -18,
                                      child: _ArrowOverlayButton(
                                        icon: Icons.chevron_right_rounded,
                                        onTap: _nextTool,
                                        enabled: _toolIndex < 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (i) {
                                  final active = i == _toolIndex;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    width: active ? 18 : 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? const Color(0xFF7C5CFF)
                                          : const Color(0xFFCBD5E1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 26),
                              Text(
                                "Your Progress",
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const _FakeProgressCard(),
                              const SizedBox(height: 18),
                              Text(
                                "Tips for you",
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const _RandomTipCard(),
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
              color: const Color(0xFF7C5CFF).withOpacity(0.22),
            ),
          ),
          Positioned(
            top: 120,
            right: -130,
            child: _BlurBlob(
              size: 340,
              color: const Color(0xFF2DD4FF).withOpacity(0.18),
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

class _ArrowOverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _ArrowOverlayButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.25,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiToolCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final String buttonText;
  final VoidCallback onTap;

  // 👇 PNG пингвин
  final String imagePath;

  const _AiToolCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.buttonText,
    required this.onTap,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: gradient),
            ),
          ),

          // Blur blob (для красоты)
          Positioned(
            top: -60,
            right: -50,
            child: _BlurBlob(
              size: 200,
              color: Colors.white.withOpacity(0.22),
            ),
          ),

          // 🐧 Penguin image
          Positioned(
            bottom: -8,
            right: -14,
            child: Opacity(
              opacity: 0.98,
              child: Image.asset(
                imagePath,
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Content
          Padding(
            // 👇 справа оставляем место для пингвина
            padding: const EdgeInsets.fromLTRB(16, 16, 130, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon box
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.20)),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),

                const SizedBox(height: 10),

                // Title
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                // Description
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),

                const Spacer(),

                // Button
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeProgressCard extends StatelessWidget {
  const _FakeProgressCard();

  @override
  Widget build(BuildContext context) {
    const percent = 0.62;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 14),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
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
                      "Interview Readiness",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "You are almost ready to apply 🚀",
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
                "${(percent * 100).round()}%",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF7C5CFF)),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _ProgressChip(
                text: "Resume uploaded",
                done: true,
              ),
              _ProgressChip(
                text: "Resume analyzed",
                done: false,
              ),
              _ProgressChip(
                text: "Mock interview",
                done: true,
              ),
              _ProgressChip(
                text: "Cover letter",
                done: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  final String text;
  final bool done;

  const _ProgressChip({
    required this.text,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color:
              done ? const Color(0xFF86EFAC) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: done ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: done ? const Color(0xFF14532D) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _RandomTipCard extends StatefulWidget {
  const _RandomTipCard();

  @override
  State<_RandomTipCard> createState() => _RandomTipCardState();
}

class _RandomTipCardState extends State<_RandomTipCard> {
  late final Map<String, dynamic> _tip;

  final List<Map<String, dynamic>> _tips = [
    {
      "title": "Interview tip",
      "text":
          "Before answering, pause 2 seconds. It makes you sound confident, not nervous.",
      "icon": Icons.mic_rounded,
    },
    {
      "title": "Job search tip",
      "text":
          "Apply through LinkedIn + also send a short message to the recruiter. It doubles your chances.",
      "icon": Icons.work_outline_rounded,
    },
    {
      "title": "Resume tip",
      "text":
          "Replace 'Responsible for' with strong verbs: Built, Improved, Delivered, Automated.",
      "icon": Icons.description_outlined,
    },
    {
      "title": "Portfolio tip",
      "text":
          "Put your best project first. Recruiters often look only at the first 20 seconds.",
      "icon": Icons.folder_open_rounded,
    },
    {
      "title": "Interview tip",
      "text":
          "Use the STAR method: Situation → Task → Action → Result. Keep it short and clear.",
      "icon": Icons.psychology_alt_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tips.shuffle();
    _tip = _tips.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
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
            child: Icon(
              _tip["icon"],
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tip["title"],
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _tip["text"],
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
