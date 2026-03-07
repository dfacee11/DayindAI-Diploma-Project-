import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/visa_city.dart';

class VisaCitySelector extends StatefulWidget {
  final void Function(VisaCity city, VisaApplicantType type) onStart;

  const VisaCitySelector({super.key, required this.onStart});

  @override
  State<VisaCitySelector> createState() => _VisaCitySelectorState();
}

class _VisaCitySelectorState extends State<VisaCitySelector> {
  VisaCity?         _selectedCity;
  VisaApplicantType _applicantType = VisaApplicantType.firstTime;

  // Берём язык UI из контекста приложения
  String get _lang => Localizations.localeOf(context).languageCode; // 'en', 'ru', 'kk'
  bool get _isRu => _lang == 'ru';
  bool get _isKk => _lang == 'kk';

  String get _subtitleText {
    if (_isRu) return "Подготовься к визовому интервью\nс реальными вопросами консулов";
    if (_isKk) return "Консулдың нақты сұрақтарымен\nвизалық сұхбатқа дайындал";
    return "Prepare for your visa interview\nwith real consular questions";
  }

  String get _applicantTypeLabel {
    if (_isRu) return "Тип участника";
    if (_isKk) return "Қатысушы түрі";
    return "Applicant Type";
  }

  String get _consularLabel {
    if (_isRu) return "Выберите консульство";
    if (_isKk) return "Консульствоны таңдаңыз";
    return "Select Consulate";
  }

  String get _tipsTitle {
    if (_isRu) return "💡 Советы для интервью";
    if (_isKk) return "💡 Сұхбатқа кеңестер";
    return "💡 Interview Tips";
  }

  List<String> get _tips {
    if (_isRu) return [
      "Отвечай уверенно и чётко",
      "Говори правду — консулы опытные",
      "Знай своё рабочее место и штат",
      "Покажи крепкую связь с Казахстаном",
    ];
    if (_isKk) return [
      "Сенімді және нақты жауап бер",
      "Шындықты айт — консулдар тәжірибелі",
      "Жұмыс орнын және штатты біл",
      "Қазақстанмен байланысыңды көрсет",
    ];
    return [
      "Answer confidently and clearly",
      "Be honest — consuls are experienced",
      "Know your workplace and state",
      "Show strong ties to Kazakhstan",
    ];
  }

  String get _startButtonText {
    if (_selectedCity == null) {
      if (_isRu) return "Выберите консульство";
      if (_isKk) return "Консульствоны таңдаңыз";
      return "Select a Consulate";
    }
    if (_isRu) return "Начать интервью";
    if (_isKk) return "Сұхбатты бастау";
    return "Start Interview";
  }

  String _cityLabel(VisaCity city) {
    if (_isRu) return "${city.displayName} Консульство";
    if (_isKk) return "${city.displayName} Консульствосы";
    return "${city.displayName} Consulate";
  }

  String _cityQuestions(VisaCity city) {
    if (_isRu) return "${city.minQ}–${city.maxQ} случайных вопросов";
    if (_isKk) return "${city.minQ}–${city.maxQ} кездейсоқ сұрақ";
    return "${city.minQ}–${city.maxQ} random questions";
  }

  String _typeLabel(VisaApplicantType type) {
    final isFirst = type == VisaApplicantType.firstTime;
    if (_isRu) return isFirst ? "Первый раз" : "Повторник";
    if (_isKk) return isFirst ? "Бірінші рет" : "Қайта өтуші";
    return isFirst ? "First Time" : "Returning";
  }

  String _typeDesc(VisaApplicantType type) {
    final isFirst = type == VisaApplicantType.firstTime;
    if (_isRu) return isFirst ? "Никогда не участвовал в W&T" : "Уже был в W&T раньше";
    if (_isKk) return isFirst ? "W&T-ге бірінші рет қатысам" : "Бұрын W&T-ге қатысқанмын";
    return isFirst ? "Never participated in W&T" : "Previously participated in W&T";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Avatar ──
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0.04)],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: const Center(child: Text("🇺🇸", style: TextStyle(fontSize: 60))),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text("Work & Travel", style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 6),
            Text(
              _subtitleText,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.65), height: 1.4),
            ),

            const SizedBox(height: 24),

            // ── APPLICANT TYPE ──
            _sectionLabel(_applicantTypeLabel),
            const SizedBox(height: 10),
            Row(
              children: VisaApplicantType.values.map((type) {
                final isSelected = _applicantType == type;
                final isLast = type == VisaApplicantType.returner;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _applicantType = type),
                    child: Container(
                      margin: EdgeInsets.only(right: isLast ? 0 : 10),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF7C5CFF).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF7C5CFF) : Colors.white.withValues(alpha: 0.12),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            type == VisaApplicantType.firstTime ? "🌱" : "⭐",
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _typeLabel(type),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 12, fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _typeDesc(type),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 10, fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(Icons.check_circle_rounded, color: Color(0xFF7C5CFF), size: 16),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // ── CONSULATE ──
            _sectionLabel(_consularLabel),
            const SizedBox(height: 10),

            ...VisaCity.values.map((city) => GestureDetector(
              onTap: () => setState(() => _selectedCity = city),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedCity == city ? const Color(0xFF7C5CFF).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedCity == city ? const Color(0xFF7C5CFF) : Colors.white.withValues(alpha: 0.12),
                    width: _selectedCity == city ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(city.flag, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_cityLabel(city), style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                          Text(_cityQuestions(city), style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    if (_selectedCity == city)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF7C5CFF), size: 22),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 10),

            // ── TIPS ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_tipsTitle, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 8),
                  ..._tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Text("•  ", style: TextStyle(color: Color(0xFF7C5CFF), fontWeight: FontWeight.w900)),
                        Expanded(child: Text(tip, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7)))),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _selectedCity == null
                    ? null
                    : () => widget.onStart(_selectedCity!, _applicantType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C5CFF),
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                child: Text(
                  _startButtonText,
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.7))),
  );
}