import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dayindai/HomePage/widgets/dark_background.dart';
import 'package:dayindai/locale_notifier.dart';
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

  List<ToolItem> _allTools(String langCode) {
    final t = _ToolsL10n.of(langCode);
    return [
      // ── AI Tools ──
      ToolItem(
        category: t.catAiTools,
        title: t.aiInterviewTitle,
        subtitle: t.aiInterviewSub,
        icon: Icons.mic_rounded,
        color: const Color(0xFF7C5CFF),
        onTap: () => Navigator.pushNamed(context, "/AIInterview"),
      ),
      ToolItem(
        category: t.catAiTools,
        title: t.resumeAnalyzerTitle,
        subtitle: t.resumeAnalyzerSub,
        icon: Icons.document_scanner_rounded,
        color: const Color(0xFF3B82F6),
        onTap: () => Navigator.pushNamed(context, "/AnalyzerResume"),
      ),
      ToolItem(
        category: t.catAiTools,
        title: t.resumeMatchingTitle,
        subtitle: t.resumeMatchingSub,
        icon: Icons.center_focus_strong_rounded,
        color: const Color(0xFF06B6D4),
        onTap: () => Navigator.pushNamed(context, "/ResumeMatching"),
      ),
      ToolItem(
        category: t.catAiTools,
        title: t.visaInterviewTitle,
        subtitle: t.visaInterviewSub,
        icon: Icons.flight_takeoff_rounded,
        color: const Color(0xFFF97316),
        onTap: () => Navigator.pushNamed(context, "/VisaInterview"),
      ),

      // ── Career Tools (merged) ──
      ToolItem(
        category: t.catCareerTools,
        title: t.resumeTemplatesTitle,
        subtitle: t.resumeTemplatesSub,
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFFF59E0B),
        onTap: () => Navigator.pushNamed(context, "/ResumeTemplates"),
      ),
      ToolItem(
        category: t.catCareerTools,
        title: t.coverLetterTitle,
        subtitle: t.coverLetterSub,
        icon: Icons.draw_rounded,
        color: const Color(0xFFEC4899),
        onTap: () => Navigator.pushNamed(context, "/CoverLetter"),
      ),
      ToolItem(
        category: t.catCareerTools,
        title: t.questionBankTitle,
        subtitle: t.questionBankSub,
        icon: Icons.lightbulb_rounded,
        color: const Color(0xFF10B981),
        onTap: () {},
      ),
      ToolItem(
        category: t.catCareerTools,
        title: t.jobSearchTitle,
        subtitle: t.jobSearchSub,
        icon: Icons.search_rounded,
        color: const Color(0xFFEF4444),
        onTap: () => Navigator.pushNamed(context, "/JobSearch"),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final t = _ToolsL10n.of(langCode);
    final currentLocale = langCode;

    const langs = [
      {'code': 'en', 'flag': '🇬🇧', 'label': 'EN'},
      {'code': 'ru', 'flag': '🇷🇺', 'label': 'RU'},
      {'code': 'kk', 'flag': '🇰🇿', 'label': 'KZ'},
    ];
    final current = langs.firstWhere(
      (l) => l['code'] == currentLocale,
      orElse: () => langs[0],
    );

    final all = _allTools(langCode);

    final filtered = all.where((tool) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return tool.title.toLowerCase().contains(q) ||
          tool.subtitle.toLowerCase().contains(q) ||
          tool.category.toLowerCase().contains(q);
    }).toList();

    final aiTools = filtered
        .where((t) => t.category == _ToolsL10n.of(langCode).catAiTools)
        .toList();
    final careerTools = filtered
        .where((t) => t.category == _ToolsL10n.of(langCode).catCareerTools)
        .toList();

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
          PopupMenuButton<String>(
            tooltip: '',
            color: const Color(0xFF1E293B),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            offset: const Offset(0, 50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(current['flag']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 5),
                  Text(current['label']!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white, size: 16),
                ],
              ),
            ),
            onSelected: (code) =>
                LocaleNotifier.of(context)?.setLocale(Locale(code)),
            itemBuilder: (_) => langs.map((lang) {
              final isActive = lang['code'] == currentLocale;
              return PopupMenuItem<String>(
                value: lang['code'],
                child: Row(
                  children: [
                    Text(lang['flag']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(lang['label']!,
                        style: TextStyle(
                          color:
                              isActive ? const Color(0xFF4C63FF) : Colors.white,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 15,
                        )),
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
            onPressed: () => Navigator.pop(context),
          ),
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
            child: Container(color: const Color(0xFFF4F5FA)),
          ),
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
                          topRight: Radius.circular(34),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.pageTitle,
                                style: GoogleFonts.montserrat(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            Text(t.pageSubtitle,
                                style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B))),
                            const SizedBox(height: 18),
                            ToolsSearchBar(
                              controller: _searchController,
                              onChanged: (v) => setState(() => _query = v),
                            ),
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
                                      Text(t.noToolsFound,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                              ),
                            if (aiTools.isNotEmpty) ...[
                              ToolsSection(title: t.catAiTools, tools: aiTools),
                              const SizedBox(height: 24),
                            ],
                            if (careerTools.isNotEmpty) ...[
                              ToolsSection(
                                  title: t.catCareerTools,
                                  tools: careerTools,
                                  useGrid: true),
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

class _ToolsL10n {
  final String pageTitle;
  final String pageSubtitle;
  final String noToolsFound;
  final String catAiTools;
  final String catCareerTools;
  final String aiInterviewTitle;
  final String aiInterviewSub;
  final String resumeAnalyzerTitle;
  final String resumeAnalyzerSub;
  final String resumeMatchingTitle;
  final String resumeMatchingSub;
  final String jobSearchTitle;
  final String jobSearchSub;
  final String resumeTemplatesTitle;
  final String resumeTemplatesSub;
  final String coverLetterTitle;
  final String coverLetterSub;
  final String questionBankTitle;
  final String questionBankSub;
  final String visaInterviewTitle;
  final String visaInterviewSub;

  const _ToolsL10n({
    required this.pageTitle,
    required this.pageSubtitle,
    required this.noToolsFound,
    required this.catAiTools,
    required this.catCareerTools,
    required this.aiInterviewTitle,
    required this.aiInterviewSub,
    required this.resumeAnalyzerTitle,
    required this.resumeAnalyzerSub,
    required this.resumeMatchingTitle,
    required this.resumeMatchingSub,
    required this.jobSearchTitle,
    required this.jobSearchSub,
    required this.resumeTemplatesTitle,
    required this.resumeTemplatesSub,
    required this.coverLetterTitle,
    required this.coverLetterSub,
    required this.questionBankTitle,
    required this.questionBankSub,
    required this.visaInterviewTitle,
    required this.visaInterviewSub,
  });

  static _ToolsL10n of(String langCode) {
    switch (langCode) {
      case 'ru':
        return const _ToolsL10n(
          pageTitle: 'Инструменты',
          pageSubtitle: 'Найдите нужный инструмент для карьеры',
          noToolsFound: 'Ничего не найдено',
          catAiTools: 'AI Инструменты',
          catCareerTools: 'Career Tools',
          aiInterviewTitle: 'AI Интервью',
          aiInterviewSub: 'Практика интервью и обратная связь',
          resumeAnalyzerTitle: 'Анализ резюме',
          resumeAnalyzerSub: 'AI-анализ вашего резюме',
          resumeMatchingTitle: 'Совпадение резюме',
          resumeMatchingSub: 'Проверьте резюме под вакансию',
          jobSearchTitle: 'Поиск вакансий',
          jobSearchSub: 'Актуальные вакансии с HH.ru',
          resumeTemplatesTitle: 'Конструктор резюме',
          resumeTemplatesSub: 'Готовые дизайны CV',
          coverLetterTitle: 'Сопроводительное письмо',
          coverLetterSub: 'AI-конструктор письма',
          questionBankTitle: 'Банк вопросов',
          questionBankSub: 'Частые вопросы на интервью',
          visaInterviewTitle: 'Интервью на визу',
          visaInterviewSub: 'Подготовка к визовому интервью',
        );
      case 'kk':
        return const _ToolsL10n(
          pageTitle: 'Құралдар',
          pageSubtitle: 'Мансабыңызға қажетті құралды табыңыз',
          noToolsFound: 'Ештеңе табылмады',
          catAiTools: 'AI Құралдары',
          catCareerTools: 'Career Tools',
          aiInterviewTitle: 'AI Сұхбат',
          aiInterviewSub: 'Сұхбат жаттығуы және кері байланыс',
          resumeAnalyzerTitle: 'Түйіндемені талдау',
          resumeAnalyzerSub: 'AI арқылы түйіндемені тексеру',
          resumeMatchingTitle: 'Түйіндемені сәйкестендіру',
          resumeMatchingSub: 'Түйіндемені вакансияға тексеру',
          jobSearchTitle: 'Жұмыс іздеу',
          jobSearchSub: 'HH.ru-дан өзекті вакансиялар',
          resumeTemplatesTitle: 'Түйіндеме жасау',
          resumeTemplatesSub: 'Дайын CV дизайндары',
          coverLetterTitle: 'Ілеспе хат',
          coverLetterSub: 'AI хат құрастырушы',
          questionBankTitle: 'Сұрақтар банкі',
          questionBankSub: 'Жиі қойылатын сұхбат сұрақтары',
          visaInterviewTitle: 'Виза сұхбаты',
          visaInterviewSub: 'Виза сұхбатына дайындық',
        );
      default:
        return const _ToolsL10n(
          pageTitle: 'Tools',
          pageSubtitle: 'Find the right tool for your career journey',
          noToolsFound: 'No tools found',
          catAiTools: 'AI Tools',
          catCareerTools: 'Career Tools',
          aiInterviewTitle: 'AI Interview',
          aiInterviewSub: 'Practice interviews & get feedback',
          resumeAnalyzerTitle: 'Resume Analyzer',
          resumeAnalyzerSub: 'AI-powered resume review',
          resumeMatchingTitle: 'Resume Matching',
          resumeMatchingSub: 'Match your resume to a job',
          jobSearchTitle: 'Job Search',
          jobSearchSub: 'Latest vacancies from HH.ru',
          resumeTemplatesTitle: 'Resume Maker',
          resumeTemplatesSub: 'Ready-to-use CV designs',
          coverLetterTitle: 'Cover Letter',
          coverLetterSub: 'AI cover letter builder',
          questionBankTitle: 'Question Bank',
          questionBankSub: 'Common interview questions',
          visaInterviewTitle: 'Visa Interview',
          visaInterviewSub: 'Prepare for visa interview',
        );
    }
  }
}
