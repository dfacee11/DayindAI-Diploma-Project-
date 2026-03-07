import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dayindai/HomePage/widgets/dark_background.dart';
import ' cover_letter_provider.dart';

// Reuse WhiteCard from AnalyzeResume
class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: child,
  );
}

class CoverLetterPage extends StatelessWidget {
  const CoverLetterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CoverLetterProvider(),
      child: const _CoverLetterView(),
    );
  }
}

class _CoverLetterView extends StatefulWidget {
  const _CoverLetterView();

  @override
  State<_CoverLetterView> createState() => _CoverLetterViewState();
}

class _CoverLetterViewState extends State<_CoverLetterView> {
  final _jobTitleCtrl = TextEditingController();
  final _companyCtrl  = TextEditingController();
  final _jobDescCtrl  = TextEditingController();
  final _aboutMeCtrl  = TextEditingController();

  @override
  void dispose() {
    _jobTitleCtrl.dispose();
    _companyCtrl.dispose();
    _jobDescCtrl.dispose();
    _aboutMeCtrl.dispose();
    super.dispose();
  }

  // ── Localized strings ──────────────────────────────────────────────────
  String get _lang => Localizations.localeOf(context).languageCode;
  bool get _isRu   => _lang == 'ru';
  bool get _isKk   => _lang == 'kk';

  String get _pageTitle {
    if (_isRu) return "Сопроводительное письмо";
    if (_isKk) return "Қолдау хаты";
    return "Cover Letter";
  }

  String get _subtitle {
    if (_isRu) return "Создай профессиональное письмо с помощью AI";
    if (_isKk) return "AI көмегімен кәсіби хат жаз";
    return "Generate a professional letter with AI";
  }

  String get _jobTitleLabel {
    if (_isRu) return "Должность";
    if (_isKk) return "Лауазым";
    return "Job Title";
  }

  String get _jobTitleHint {
    if (_isRu) return "Flutter Developer, Product Manager...";
    if (_isKk) return "Flutter Developer, Product Manager...";
    return "Flutter Developer, Product Manager...";
  }

  String get _companyLabel {
    if (_isRu) return "Компания";
    if (_isKk) return "Компания";
    return "Company";
  }

  String get _companyHint {
    if (_isRu) return "Название компании";
    if (_isKk) return "Компания атауы";
    return "Company name";
  }

  String get _jobDescLabel {
    if (_isRu) return "Описание вакансии";
    if (_isKk) return "Вакансия сипаттамасы";
    return "Job Description";
  }

  String get _jobDescHint {
    if (_isRu) return "Вставьте описание вакансии (необязательно)";
    if (_isKk) return "Вакансия сипаттамасын қойыңыз (міндетті емес)";
    return "Paste the job description (optional)";
  }

  String get _aboutMeLabel {
    if (_isRu) return "О себе";
    if (_isKk) return "Өзім туралы";
    return "About Me";
  }

  String get _aboutMeHint {
    if (_isRu) return "Опыт, навыки, достижения (необязательно)";
    if (_isKk) return "Тәжірибе, дағдылар, жетістіктер (міндетті емес)";
    return "Experience, skills, achievements (optional)";
  }

  String get _languageLabel {
    if (_isRu) return "Язык письма";
    if (_isKk) return "Хат тілі";
    return "Letter Language";
  }

  String get _generateBtn {
    if (_isRu) return "Создать письмо";
    if (_isKk) return "Хат жасау";
    return "Generate Letter";
  }

  String get _resultTitle {
    if (_isRu) return "Ваше письмо готово";
    if (_isKk) return "Хатыңыз дайын";
    return "Your Letter is Ready";
  }

  String get _copyBtn {
    if (_isRu) return "Копировать";
    if (_isKk) return "Көшіру";
    return "Copy";
  }

  String get _copiedMsg {
    if (_isRu) return "Скопировано!";
    if (_isKk) return "Көшірілді!";
    return "Copied!";
  }

  String get _regenerateBtn {
    if (_isRu) return "Создать заново";
    if (_isKk) return "Қайта жасау";
    return "Regenerate";
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CoverLetterProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(_pageTitle,
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
      body: Stack(
        children: [
          const DarkTopBackground(),
          Positioned(top: 200, left: 0, right: 0, bottom: 0, child: Container(color: const Color(0xFFF4F5FA))),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    width: double.infinity,
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
                          Text(_pageTitle,
                              style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                          const SizedBox(height: 6),
                          Text(_subtitle,
                              style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                          const SizedBox(height: 20),

                          // ── Job Title ──
                          _sectionLabel(_jobTitleLabel, required: true),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _jobTitleCtrl,
                            hint: _jobTitleHint,
                            icon: Icons.work_outline_rounded,
                            onChanged: p.setJobTitle,
                          ),
                          const SizedBox(height: 14),

                          // ── Company ──
                          _sectionLabel(_companyLabel, required: true),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _companyCtrl,
                            hint: _companyHint,
                            icon: Icons.business_rounded,
                            onChanged: p.setCompany,
                          ),
                          const SizedBox(height: 14),

                          // ── Job Description ──
                          _sectionLabel(_jobDescLabel),
                          const SizedBox(height: 8),
                          _buildTextArea(
                            controller: _jobDescCtrl,
                            hint: _jobDescHint,
                            icon: Icons.description_outlined,
                            onChanged: p.setJobDesc,
                            maxLines: 5,
                          ),
                          const SizedBox(height: 14),

                          // ── About Me ──
                          _sectionLabel(_aboutMeLabel),
                          const SizedBox(height: 8),
                          _buildTextArea(
                            controller: _aboutMeCtrl,
                            hint: _aboutMeHint,
                            icon: Icons.person_outline_rounded,
                            onChanged: p.setAboutMe,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 14),

                          // ── Language ──
                          _sectionLabel(_languageLabel),
                          const SizedBox(height: 10),
                          _buildLanguagePicker(p),
                          const SizedBox(height: 22),

                          // ── Generate Button ──
                          _buildGenerateButton(p),
                          const SizedBox(height: 24),

                          // ── Result ──
                          if (p.error != null) _buildError(p.error!),
                          if (p.result != null) _buildResult(p),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(text,
            style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        if (required) ...[
          const SizedBox(width: 4),
          Text("*", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF7C5CFF))),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required void Function(String) onChanged,
  }) {
    return _WhiteCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: GoogleFonts.montserrat(color: const Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(color: const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required void Function(String) onChanged,
    int maxLines = 4,
  }) {
    return _WhiteCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                maxLines: maxLines,
                minLines: 2,
                style: GoogleFonts.montserrat(color: const Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w600, height: 1.5),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: GoogleFonts.montserrat(color: const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePicker(CoverLetterProvider p) {
    return Row(
      children: CoverLetterLanguage.values.map((lang) {
        final isSelected = p.language == lang;
        final isLast = lang == CoverLetterLanguage.kazakh;
        return Expanded(
          child: GestureDetector(
            onTap: () => p.setLanguage(lang),
            child: Container(
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF7C5CFF).withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF7C5CFF) : const Color(0xFFE2E8F0),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  Text(lang.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(lang.label,
                      style: GoogleFonts.montserrat(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        color: isSelected ? const Color(0xFF7C5CFF) : const Color(0xFF64748B),
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenerateButton(CoverLetterProvider p) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (p.isGenerating || !p.canGenerate) ? null : p.generate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C5CFF),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: p.isGenerating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                  const SizedBox(width: 12),
                  Text(_isRu ? "Генерирую..." : _isKk ? "Жасалуда..." : "Generating...",
                      style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              )
            : Text(_generateBtn,
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildResult(CoverLetterProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)],
                ),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_resultTitle,
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Letter card
        _WhiteCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              p.result!,
              style: GoogleFonts.lato(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1E293B),
                height: 1.7,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Action buttons
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: p.result!));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(_copiedMsg,
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                      backgroundColor: const Color(0xFF22C55E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(_copyBtn, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C5CFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () { p.reset(); },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(_regenerateBtn, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7C5CFF),
                    side: const BorderSide(color: Color(0xFF7C5CFF), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildError(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isRu ? "Ошибка генерации. Попробуйте снова." : _isKk ? "Қате. Қайталап көріңіз." : "Generation failed. Please try again.",
              style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}