import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/visa_city.dart';
import '../visa_interview_provider.dart';

class VisaCitySelector extends StatefulWidget {
  final void Function(VisaCity city) onStart;

  const VisaCitySelector({super.key, required this.onStart});

  @override
  State<VisaCitySelector> createState() => _VisaCitySelectorState();
}

class _VisaCitySelectorState extends State<VisaCitySelector> {
  VisaCity? _selected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
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
              "Подготовься к визовому интервью\nс реальными вопросами консулов",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.65), height: 1.4),
            ),

            const SizedBox(height: 32),

            // Info cards
            Row(
              children: [
                _buildInfoCard("🏛️", "Астана", "6–9 вопросов", "Более детальное интервью"),
                const SizedBox(width: 12),
                _buildInfoCard("🏔️", "Алматы", "3–5 вопросов", "Короткое интервью"),
              ],
            ),

            const SizedBox(height: 20),

            // City selector
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Выберите консульство", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.7))),
            ),
            const SizedBox(height: 10),

            ...VisaCity.values.map((city) => GestureDetector(
              onTap: () => setState(() => _selected = city),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: _selected == city ? const Color(0xFF7C5CFF).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selected == city ? const Color(0xFF7C5CFF) : Colors.white.withValues(alpha: 0.12),
                    width: _selected == city ? 2 : 1,
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
                          Text("${city.displayName} Консульство", style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                          Text("${city.minQ}–${city.maxQ} случайных вопросов", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    if (_selected == city)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF7C5CFF), size: 22),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 10),

            // Tips
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
                  Text("💡 Советы для интервью", style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 8),
                  ...["Отвечай уверенно и чётко", "Говори правду — консулы опытные", "Знай своё рабочее место и штат", "Покажи крепкую связь с Казахстаном"].map((tip) => Padding(
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
                onPressed: _selected == null ? null : () => widget.onStart(_selected!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C5CFF),
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                child: Text(
                  _selected == null ? "Выберите консульство" : "Начать интервью",
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String emoji, String city, String count, String desc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(city, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
            Text(count, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF7C5CFF))),
            const SizedBox(height: 2),
            Text(desc, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}