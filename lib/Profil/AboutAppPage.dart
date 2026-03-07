import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final t = _L10n.of(langCode);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // App hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(blurRadius: 20, offset: const Offset(0, 8), color: Colors.black.withOpacity(0.06))],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset('assets/images/aipenguin.png', width: 90, height: 90),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'Dayind', style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                        TextSpan(text: 'AI', style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w900, color: const Color(0xFF7C5CFF))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(t.tagline, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EDFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('v1.0.0', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF7C5CFF))),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info section
            _sectionLabel(t.sectionInfo),
            const SizedBox(height: 10),
            _infoCard([
              _infoRow(Icons.code_rounded,        const Color(0xFF7C5CFF), t.developer,  'Dilmurod Zaitkhanov'),
              _infoRow(Icons.school_rounded,       const Color(0xFF3B82F6), t.university, 'SDU University'),
              _infoRow(Icons.language_rounded,     const Color(0xFF10B981), t.languages,  'KZ · RU · EN'),
              _infoRow(Icons.phone_iphone_rounded, const Color(0xFFF59E0B), t.platform,   'iOS · Android'),
            ]),

            const SizedBox(height: 20),

            // Contact section
            _sectionLabel(t.sectionContact),
            const SizedBox(height: 10),
            _infoCard([
              _infoRow(Icons.email_outlined,    const Color(0xFFEF4444), t.email,    'support@dayindai.app'),
              _infoRow(Icons.telegram_rounded,  const Color(0xFF3B82F6), t.telegram, '@dayindai'),
            ]),

            const SizedBox(height: 20),

            // Tech stack
            _sectionLabel(t.sectionTech),
            const SizedBox(height: 10),
            _infoCard([
              _infoRow(Icons.flutter_dash_rounded, const Color(0xFF06B6D4), 'Flutter',  'Cross-platform'),
              _infoRow(Icons.cloud_rounded,         const Color(0xFFF59E0B), 'Firebase', 'Backend'),
              _infoRow(Icons.psychology_rounded,    const Color(0xFF7C5CFF), 'Claude AI', 'Anthropic'),
            ]),

            const SizedBox(height: 28),

            // Copyright
            Text(
              '© 2025 DayindAI\n${t.rights}',
              style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8), height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text('Made with ❤️ in Kazakhstan', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
  );

  Widget _infoCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(blurRadius: 16, offset: const Offset(0, 4), color: Colors.black.withOpacity(0.05))],
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          return Column(children: [
            e.value,
            if (!isLast) Divider(height: 1, indent: 56, endIndent: 16, color: Colors.black.withOpacity(0.05)),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _infoRow(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Text(label, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
          const Spacer(),
          Text(value, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

class _L10n {
  final String title, tagline;
  final String sectionInfo, sectionContact, sectionTech;
  final String developer, university, languages, platform;
  final String email, telegram;
  final String rights;

  const _L10n({
    required this.title, required this.tagline,
    required this.sectionInfo, required this.sectionContact, required this.sectionTech,
    required this.developer, required this.university, required this.languages, required this.platform,
    required this.email, required this.telegram, required this.rights,
  });

  static _L10n of(String l) => switch (l) {
    'ru' => const _L10n(
      title: 'О DayindAI', tagline: 'Твой AI карьерный коуч',
      sectionInfo: 'ИНФОРМАЦИЯ', sectionContact: 'КОНТАКТЫ', sectionTech: 'ТЕХНОЛОГИИ',
      developer: 'Разработчик', university: 'Университет', languages: 'Языки', platform: 'Платформа',
      email: 'Email', telegram: 'Telegram',
      rights: 'Все права защищены',
    ),
    'kk' => const _L10n(
      title: 'DayindAI туралы', tagline: 'Сенің AI мансап коучың',
      sectionInfo: 'АҚПАРАТ', sectionContact: 'БАЙЛАНЫС', sectionTech: 'ТЕХНОЛОГИЯЛАР',
      developer: 'Әзірлеуші', university: 'Университет', languages: 'Тілдер', platform: 'Платформа',
      email: 'Email', telegram: 'Telegram',
      rights: 'Барлық құқықтар қорғалған',
    ),
    _ => const _L10n(
      title: 'About DayindAI', tagline: 'Your AI Career Coach',
      sectionInfo: 'INFORMATION', sectionContact: 'CONTACT', sectionTech: 'TECHNOLOGY',
      developer: 'Developer', university: 'University', languages: 'Languages', platform: 'Platform',
      email: 'Email', telegram: 'Telegram',
      rights: 'All rights reserved',
    ),
  };
}