import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final _searchController = TextEditingController();
  String _query = '';
  int? _expandedIndex;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final t = _L10n.of(langCode);
    final filtered = t.faqs.where((f) {
      if (_query.isEmpty) return true;
      return f[0].toLowerCase().contains(_query.toLowerCase()) ||
             f[1].toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(t.title, style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.15))),
              child: Row(
                children: [
                  const Padding(padding: EdgeInsets.only(left: 14), child: Icon(Icons.search_rounded, color: Colors.white54, size: 20)),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: t.searchHint,
                        hintStyle: GoogleFonts.montserrat(color: Colors.white38, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      onChanged: (v) => setState(() { _query = v; _expandedIndex = null; }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick actions
                  if (_query.isEmpty) ...[
                    Text(t.quickActions, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _quickBtn(Icons.email_outlined, t.emailUs, const Color(0xFF7C5CFF)),
                        const SizedBox(width: 10),
                        _quickBtn(Icons.telegram, t.telegram, const Color(0xFF3B82F6)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(t.faqTitle, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                  ],

                  // FAQ list
                  if (filtered.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            const Text('🐧', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(t.noResults, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(blurRadius: 16, offset: const Offset(0, 4), color: Colors.black.withOpacity(0.05))],
                      ),
                      child: Column(
                        children: filtered.asMap().entries.map((entry) {
                          final i = entry.key;
                          final faq = entry.value;
                          final isLast = i == filtered.length - 1;
                          final isExpanded = _expandedIndex == i;
                          return Column(
                            children: [
                              InkWell(
                                onTap: () => setState(() => _expandedIndex = isExpanded ? null : i),
                                borderRadius: BorderRadius.vertical(
                                  top: i == 0 ? const Radius.circular(20) : Radius.zero,
                                  bottom: isLast ? const Radius.circular(20) : Radius.zero,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 32, height: 32,
                                            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                            child: Center(child: Text('${i + 1}', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF10B981)))),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(child: Text(faq[0], style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)))),
                                          Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: const Color(0xFF94A3B8)),
                                        ],
                                      ),
                                      if (isExpanded) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                                          child: Text(faq[1], style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF475569), height: 1.6)),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              if (!isLast) Divider(height: 1, indent: 16, endIndent: 16, color: Colors.black.withOpacity(0.05)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 24),
                  // Contact card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text('🐧', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.stillNeedHelp, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                              const SizedBox(height: 2),
                              Text('dilmurodzaitkh@gmail.com', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickBtn(IconData icon, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(blurRadius: 12, offset: const Offset(0, 4), color: Colors.black.withOpacity(0.05))],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
            ],
          ),
        ),
      ),
    );
  }
}

class _L10n {
  final String title, searchHint, quickActions, emailUs, telegram;
  final String faqTitle, noResults, stillNeedHelp;
  final List<List<String>> faqs;

  const _L10n({
    required this.title, required this.searchHint, required this.quickActions,
    required this.emailUs, required this.telegram, required this.faqTitle,
    required this.noResults, required this.stillNeedHelp, required this.faqs,
  });

  static _L10n of(String l) => switch (l) {
    'ru' => const _L10n(
      title: 'Центр помощи', searchHint: 'Поиск по вопросам...', quickActions: 'БЫСТРАЯ СВЯЗЬ',
      emailUs: 'Email', telegram: 'Telegram', faqTitle: 'ЧАСТО ЗАДАВАЕМЫЕ ВОПРОСЫ',
      noResults: 'Ничего не найдено', stillNeedHelp: 'Остались вопросы? Напишите нам!',
      faqs: [
        ['Как работает AI Интервью?', 'AI задаёт реальные вопросы по вашей специальности. Вы отвечаете голосом или текстом, а AI анализирует и даёт подробную обратную связь.'],
        ['Сколько интервью можно провести бесплатно?', 'На Free плане доступно 3 AI интервью в день. Pro план — безлимитно.'],
        ['Как загрузить резюме для анализа?', 'В разделе "Анализ резюме" нажмите кнопку загрузки и выберите PDF или Word файл.'],
        ['Мои данные в безопасности?', 'Да. Все данные хранятся в Firebase с шифрованием и никогда не передаются третьим лицам.'],
        ['Как изменить язык приложения?', 'Нажмите на флаг страны в правом верхнем углу любого экрана и выберите нужный язык.'],
        ['Как отменить Pro подписку?', 'В настройках App Store → Подписки → DayindAI → Отменить.'],
        ['Приложение работает без интернета?', 'Основные AI функции требуют интернет. Банк вопросов доступен офлайн.'],
      ],
    ),
    'kk' => const _L10n(
      title: 'Көмек орталығы', searchHint: 'Сұрақтар бойынша іздеу...', quickActions: 'ЖЫЛДАМ БАЙЛАНЫС',
      emailUs: 'Email', telegram: 'Telegram', faqTitle: 'ЖИІ ҚОЙЫЛАТЫН СҰРАҚТАР',
      noResults: 'Ештеңе табылмады', stillNeedHelp: 'Сұрақтар бар ма? Бізге жазыңыз!',
      faqs: [
        ['AI Сұхбат қалай жұмыс істейді?', 'AI мамандығыңыз бойынша нақты сұрақтар қояды. Дауыспен немесе мәтінмен жауап беріп, кері байланыс аласыз.'],
        ['Тегін қанша сұхбат өткізуге болады?', 'Free жоспарда күніне 3 AI сұхбат қол жетімді. Pro жоспарда шексіз.'],
        ['Түйіндемені қалай жүктеуге болады?', '"Түйіндемені талдау" бөліміндегі жүктеу түймесін басып, PDF немесе Word файлды таңдаңыз.'],
        ['Деректерім қауіпсіз бе?', 'Иә. Барлық деректер шифрлаумен Firebase-те сақталады.'],
        ['Тілді қалай өзгертуге болады?', 'Кез келген экранның жоғарғы оң жағындағы жалауды басып, тілді таңдаңыз.'],
        ['Pro жазылымды қалай болдырмауға болады?', 'App Store параметрлері → Жазылымдар → DayindAI → Болдырмау.'],
        ['Қолданба интернетсіз жұмыс істей ме?', 'Негізгі AI функциялары интернетті қажет етеді. Сұрақтар банкі офлайн қол жетімді.'],
      ],
    ),
    _ => const _L10n(
      title: 'Help Center', searchHint: 'Search questions...', quickActions: 'QUICK CONTACT',
      emailUs: 'Email', telegram: 'Telegram', faqTitle: 'FREQUENTLY ASKED QUESTIONS',
      noResults: 'No results found', stillNeedHelp: 'Still need help? Contact us!',
      faqs: [
        ['How does AI Interview work?', 'AI asks real questions based on your specialty. You answer by voice or text, and AI analyzes your response with detailed feedback.'],
        ['How many free interviews do I get?', 'Free plan: 3 AI interviews per day. Pro plan: unlimited.'],
        ['How do I upload my resume?', 'In the Resume Analyzer section, tap the upload button and select a PDF or Word file.'],
        ['Is my data safe?', 'Yes. All data is stored in Firebase with encryption and never shared with third parties.'],
        ['How do I change the app language?', 'Tap the country flag in the top right corner of any screen and select your language.'],
        ['How do I cancel my Pro subscription?', 'Go to App Store Settings → Subscriptions → DayindAI → Cancel.'],
        ['Does the app work offline?', 'Core AI features require internet. The Question Bank is available offline.'],
      ],
    ),
  };
}