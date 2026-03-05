import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dayindai/locale_notifier.dart';
import 'l10n.dart';
import 'widgets/dark_background.dart';
import 'widgets/ai_tool_card.dart';
import 'widgets/arrow_overlay_button.dart';
import 'widgets/random_tip_card.dart';
import 'widgets/last_interview_card.dart';

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
      final newIndex = (_toolController.page ?? 0).round();
      if (newIndex != _toolIndex) setState(() => _toolIndex = newIndex);
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
    final l10n = AppLocalizations.of(context);
    final displayName = _user?.displayName ?? l10n.userFallback;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, l10n),
      body: Stack(
        children: [
          const DarkTopBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    _buildMainContent(context, constraints, displayName, l10n),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n) {
    final currentLocale = Localizations.localeOf(context).languageCode;

    // flag emoji + code for each language
    const langs = [
      {'code': 'en', 'flag': '🇬🇧', 'label': 'EN'},
      {'code': 'ru', 'flag': '🇷🇺', 'label': 'RU'},
      {'code': 'kk', 'flag': '🇰🇿', 'label': 'KZ'},
    ];

    final current = langs.firstWhere(
      (l) => l['code'] == currentLocale,
      orElse: () => langs[0],
    );

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              height: 73,
              width: 73,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/DayindAI1.png', fit: BoxFit.cover),
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              text: 'Dayind',
              style: GoogleFonts.montserrat(
                fontSize: 27,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'AI',
                  style: GoogleFonts.montserrat(
                    fontSize: 27,
                    color: const Color(0xFF4C63FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // ── Language switcher with flag ──────────────────────────────────
        PopupMenuButton<String>(
          tooltip: '',
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          offset: const Offset(0, 50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(current['flag']!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 5),
                Text(
                  current['label']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white, size: 16),
              ],
            ),
          ),
          onSelected: (code) {
            LocaleNotifier.of(context)?.setLocale(Locale(code));
          },
          itemBuilder: (_) => langs.map((lang) {
            final isActive = lang['code'] == currentLocale;
            return PopupMenuItem<String>(
              value: lang['code'],
              child: Row(
                children: [
                  Text(lang['flag']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(
                    lang['label']!,
                    style: TextStyle(
                      color: isActive ? const Color(0xFF4C63FF) : Colors.white,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  if (isActive) ...[
                    const Spacer(),
                    const Icon(Icons.check_rounded,
                        size: 16, color: Color(0xFF4C63FF)),
                  ],
                ],
              ),
            );
          }).toList(),
        ),

        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: l10n.logout,
          onPressed: _signOut,
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    BoxConstraints constraints,
    String displayName,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: constraints.maxHeight - 110),
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
            _buildGreeting(displayName, l10n),
            const SizedBox(height: 22),
            _buildSectionTitle(l10n.sectionAiTools),
            const SizedBox(height: 14),
            _buildToolCarousel(context, l10n),
            const SizedBox(height: 12),
            _buildDots(),
            const SizedBox(height: 26),
            _buildSectionTitle(l10n.sectionLastInterview),
            const SizedBox(height: 12),
            LastInterviewCard(
              onTap: () => Navigator.pushNamed(context, '/AIInterview'),
            ),
            const SizedBox(height: 18),
            _buildSectionTitle(l10n.sectionTips),
            const SizedBox(height: 12),
            const RandomTipCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(String displayName, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: l10n.greetingHi,
                style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A)),
              ),
              TextSpan(
                text: '$displayName,',
                style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF4C63FF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.greetingSubtitle,
          style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF0F172A)),
    );
  }

  Widget _buildToolCarousel(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      height: 185,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: PageView(
                  controller: _toolController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    AiToolCard(
                      title: l10n.toolInterviewTitle,
                      description: l10n.toolInterviewDesc,
                      icon: Icons.record_voice_over_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)],
                      ),
                      buttonText: l10n.toolInterviewBtn,
                      imagePath: 'assets/images/pin1.png',
                      onTap: () => Navigator.pushNamed(context, '/AIInterview'),
                    ),
                    AiToolCard(
                      title: l10n.toolAnalyzerTitle,
                      description: l10n.toolAnalyzerDesc,
                      icon: Icons.description_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4F46E5), Color(0xFF38BDF8)],
                      ),
                      buttonText: l10n.toolAnalyzerBtn,
                      imagePath: 'assets/images/pin2.png',
                      onTap: () =>
                          Navigator.pushNamed(context, '/AnalyzerResume'),
                    ),
                    AiToolCard(
                      title: l10n.toolMatchingTitle,
                      description: l10n.toolMatchingDesc,
                      icon: Icons.compare_arrows_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF9333EA), Color(0xFF60A5FA)],
                      ),
                      buttonText: l10n.toolMatchingBtn,
                      imagePath: 'assets/images/pin3.png',
                      onTap: () =>
                          Navigator.pushNamed(context, '/ResumeMatching'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -18,
            child: ArrowOverlayButton(
                icon: Icons.chevron_left_rounded,
                onTap: _prevTool,
                enabled: _toolIndex > 0),
          ),
          Positioned(
            right: -18,
            child: ArrowOverlayButton(
                icon: Icons.chevron_right_rounded,
                onTap: _nextTool,
                enabled: _toolIndex < 2),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i == _toolIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF7C5CFF) : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}