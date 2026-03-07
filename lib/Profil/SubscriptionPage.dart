import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isYearly = true;

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final t = _L10n.of(langCode);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                children: [
                  // Crown
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text(t.heroTitle, style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1), textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text(t.heroSub, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white54), textAlign: TextAlign.center),
                  const SizedBox(height: 32),

                  // Features
                  ...[
                    (Icons.all_inclusive_rounded, const Color(0xFF7C5CFF), t.f1),
                    (Icons.bolt_rounded,           const Color(0xFFF59E0B), t.f2),
                    (Icons.description_rounded,    const Color(0xFF3B82F6), t.f3),
                    (Icons.mic_rounded,            const Color(0xFF10B981), t.f4),
                    (Icons.support_agent_rounded,  const Color(0xFFEC4899), t.f5),
                  ].map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: f.$2.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                          child: Icon(f.$1, color: f.$2, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Text(f.$3, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                        const Spacer(),
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                      ],
                    ),
                  )),

                  const SizedBox(height: 28),
                ],
              ),
            ),

            // ── Pricing ──
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F5FA),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
              child: Column(
                children: [
                  // Toggle monthly/yearly
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        _planToggle(t.monthly, !_isYearly, () => setState(() => _isYearly = false)),
                        _planToggle(t.yearly, _isYearly,  () => setState(() => _isYearly = true), badge: t.save),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Price card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF7C5CFF), Color(0xFF9F7AFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: const Color(0xFF7C5CFF).withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isYearly ? t.priceYearly : t.priceMonthly,
                          style: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        Text(
                          _isYearly ? t.perYear : t.perMonth,
                          style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
                        ),
                        if (_isYearly) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text(t.saveLabel, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: Text(t.ctaButton, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(t.disclaimer, style: GoogleFonts.montserrat(fontSize: 11, color: const Color(0xFF94A3B8)), textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planToggle(String label, bool active, VoidCallback onTap, {String? badge}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: active ? const Color(0xFF0F172A) : const Color(0xFF94A3B8))),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(6)),
                  child: Text(badge, style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _L10n {
  final String heroTitle, heroSub;
  final String f1, f2, f3, f4, f5;
  final String monthly, yearly, save;
  final String priceMonthly, priceYearly, perMonth, perYear, saveLabel;
  final String ctaButton, disclaimer;

  const _L10n({
    required this.heroTitle, required this.heroSub,
    required this.f1, required this.f2, required this.f3, required this.f4, required this.f5,
    required this.monthly, required this.yearly, required this.save,
    required this.priceMonthly, required this.priceYearly,
    required this.perMonth, required this.perYear, required this.saveLabel,
    required this.ctaButton, required this.disclaimer,
  });

  static _L10n of(String l) => switch (l) {
    'ru' => const _L10n(
      heroTitle: 'Стань\nPro карьеристом',
      heroSub: 'Разблокируй все возможности DayindAI',
      f1: 'Безлимитные AI интервью',
      f2: 'Приоритетные ответы AI',
      f3: 'Все шаблоны резюме',
      f4: 'Расширенная практика речи',
      f5: 'Поддержка 24/7',
      monthly: 'Месяц', yearly: 'Год', save: '-40%',
      priceMonthly: '990 ₸', priceYearly: '5 990 ₸',
      perMonth: 'в месяц', perYear: 'в год',
      saveLabel: 'Экономия 40%',
      ctaButton: 'Начать Pro бесплатно',
      disclaimer: 'Бесплатно 7 дней · Отмена в любое время',
    ),
    'kk' => const _L10n(
      heroTitle: 'Pro\nмамандыққа жет',
      heroSub: 'DayindAI барлық мүмкіндіктерін аш',
      f1: 'Шексіз AI сұхбаттар',
      f2: 'Басымдықты AI жауаптары',
      f3: 'Барлық CV үлгілері',
      f4: 'Кеңейтілген сөйлеу жаттығуы',
      f5: '24/7 қолдау',
      monthly: 'Ай', yearly: 'Жыл', save: '-40%',
      priceMonthly: '990 ₸', priceYearly: '5 990 ₸',
      perMonth: 'айына', perYear: 'жылына',
      saveLabel: '40% үнемдеу',
      ctaButton: 'Pro-ны тегін бастау',
      disclaimer: '7 күн тегін · Кез келген уақытта болдырмау',
    ),
    _ => const _L10n(
      heroTitle: 'Become a\nPro Career Seeker',
      heroSub: 'Unlock everything DayindAI has to offer',
      f1: 'Unlimited AI interviews',
      f2: 'Priority AI responses',
      f3: 'All resume templates',
      f4: 'Advanced speech practice',
      f5: '24/7 priority support',
      monthly: 'Monthly', yearly: 'Yearly', save: '-40%',
      priceMonthly: '\$2.99', priceYearly: '\$14.99',
      perMonth: 'per month', perYear: 'per year',
      saveLabel: 'Save 40%',
      ctaButton: 'Start Pro Free',
      disclaimer: '7-day free trial · Cancel anytime',
    ),
  };
}