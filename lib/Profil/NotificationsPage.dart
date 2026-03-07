import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notifInterview = true;
  bool _notifTips = true;
  bool _notifUpdates = false;
  bool _notifJobs = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifInterview = prefs.getBool('notif_interview') ?? true;
      _notifTips      = prefs.getBool('notif_tips')      ?? true;
      _notifUpdates   = prefs.getBool('notif_updates')   ?? false;
      _notifJobs      = prefs.getBool('notif_jobs')      ?? false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Header illustration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C5CFF), Color(0xFF9F7AFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Text('🔔', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.headerTitle, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(t.headerSub, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _sectionLabel(t.sectionPractice),
            const SizedBox(height: 10),
            _buildCard([
              _notifTile(
                icon: Icons.mic_rounded,
                color: const Color(0xFF7C5CFF),
                title: t.notifInterview,
                subtitle: t.notifInterviewSub,
                value: _notifInterview,
                onChanged: (v) { setState(() => _notifInterview = v); _save('notif_interview', v); },
              ),
              _notifTile(
                icon: Icons.lightbulb_rounded,
                color: const Color(0xFFF59E0B),
                title: t.notifTips,
                subtitle: t.notifTipsSub,
                value: _notifTips,
                onChanged: (v) { setState(() => _notifTips = v); _save('notif_tips', v); },
              ),
            ]),

            const SizedBox(height : 20),
            _sectionLabel(t.sectionOther),
            const SizedBox(height: 10),
            _buildCard([
              _notifTile(
                icon: Icons.search_rounded,
                color: const Color(0xFFEF4444),
                title: t.notifJobs,
                subtitle: t.notifJobsSub,
                value: _notifJobs,
                onChanged: (v) { setState(() => _notifJobs = v); _save('notif_jobs', v); },
              ),
              _notifTile(
                icon: Icons.system_update_rounded,
                color: const Color(0xFF10B981),
                title: t.notifUpdates,
                subtitle: t.notifUpdatesSub,
                value: _notifUpdates,
                onChanged: (v) { setState(() => _notifUpdates = v); _save('notif_updates', v); },
              ),
            ]),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(t.disclaimer,
                      style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8), height: 1.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5),
  );

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(blurRadius: 16, offset: const Offset(0, 4), color: Colors.black.withOpacity(0.05))],
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(children: [
            e.value,
            if (!isLast) Divider(height: 1, indent: 68, endIndent: 16, color: Colors.black.withOpacity(0.05)),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _notifTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: const Color(0xFF7C5CFF)),
        ],
      ),
    );
  }
}

class _L10n {
  final String title, headerTitle, headerSub;
  final String sectionPractice, sectionOther;
  final String notifInterview, notifInterviewSub;
  final String notifTips, notifTipsSub;
  final String notifJobs, notifJobsSub;
  final String notifUpdates, notifUpdatesSub;
  final String disclaimer;

  const _L10n({
    required this.title, required this.headerTitle, required this.headerSub,
    required this.sectionPractice, required this.sectionOther,
    required this.notifInterview, required this.notifInterviewSub,
    required this.notifTips, required this.notifTipsSub,
    required this.notifJobs, required this.notifJobsSub,
    required this.notifUpdates, required this.notifUpdatesSub,
    required this.disclaimer,
  });

  static _L10n of(String l) => switch (l) {
    'ru' => const _L10n(
      title: 'Уведомления',
      headerTitle: 'Настройте уведомления',
      headerSub: 'Получайте только нужные напоминания',
      sectionPractice: 'ПРАКТИКА',
      sectionOther: 'ПРОЧЕЕ',
      notifInterview: 'Напоминания об интервью',
      notifInterviewSub: 'Советы и напоминания о практике',
      notifTips: 'Совет дня',
      notifTipsSub: 'Ежедневные карьерные лайфхаки',
      notifJobs: 'Новые вакансии',
      notifJobsSub: 'Свежие вакансии с HH.ru',
      notifUpdates: 'Обновления приложения',
      notifUpdatesSub: 'Новые функции и исправления',
      disclaimer: 'Уведомления работают только если разрешены в настройках iPhone.',
    ),
    'kk' => const _L10n(
      title: 'Хабарландырулар',
      headerTitle: 'Хабарландыруларды баптаңыз',
      headerSub: 'Тек қажетті еске салуларды алыңыз',
      sectionPractice: 'ЖАТТЫҒУ',
      sectionOther: 'БАСҚА',
      notifInterview: 'Сұхбат еске салулары',
      notifInterviewSub: 'Жаттығу туралы кеңестер',
      notifTips: 'Күнің кеңесі',
      notifTipsSub: 'Күнделікті мансап лайфхактары',
      notifJobs: 'Жаңа вакансиялар',
      notifJobsSub: 'HH.ru-дан жаңа вакансиялар',
      notifUpdates: 'Қолданба жаңартулары',
      notifUpdatesSub: 'Жаңа мүмкіндіктер',
      disclaimer: 'Хабарландырулар iPhone параметрлерінде рұқсат етілсе ғана жұмыс істейді.',
    ),
    _ => const _L10n(
      title: 'Notifications',
      headerTitle: 'Manage Notifications',
      headerSub: 'Only get the reminders you need',
      sectionPractice: 'PRACTICE',
      sectionOther: 'OTHER',
      notifInterview: 'Interview reminders',
      notifInterviewSub: 'Tips and reminders before practice',
      notifTips: 'Daily tip',
      notifTipsSub: 'Career hacks every day',
      notifJobs: 'New vacancies',
      notifJobsSub: 'Fresh jobs from HH.ru',
      notifUpdates: 'App updates',
      notifUpdatesSub: 'New features and fixes',
      disclaimer: 'Notifications only work if allowed in iPhone Settings.',
    ),
  };
}