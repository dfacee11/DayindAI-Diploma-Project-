import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dayindai/HomePage/l10n.dart'; 

enum InterviewType { behavioral, technical, mixed }
enum InterviewLanguage { english, russian, kazakh }
enum ExperienceLevel { intern, junior, middle, senior }

extension InterviewTypeExt on InterviewType {
  String label(InterviewLanguage lang) {
    switch (lang) {
      case InterviewLanguage.russian:
        switch (this) {
          case InterviewType.behavioral: return "Behavioral";
          case InterviewType.technical:  return "Техническое";
          case InterviewType.mixed:      return "Смешанное";
        }
      case InterviewLanguage.kazakh:
        switch (this) {
          case InterviewType.behavioral: return "Behavioral";
          case InterviewType.technical:  return "Техникалық";
          case InterviewType.mixed:      return "Аралас";
        }
      default:
        switch (this) {
          case InterviewType.behavioral: return "Behavioral";
          case InterviewType.technical:  return "Technical";
          case InterviewType.mixed:      return "Mixed";
        }
    }
  }

  String description(InterviewLanguage lang) {
    switch (lang) {
      case InterviewLanguage.russian:
        switch (this) {
          case InterviewType.behavioral: return "Опыт, сильные стороны, цели";
          case InterviewType.technical:  return "Код, архитектура, технические навыки";
          case InterviewType.mixed:      return "Поведенческие и технические вопросы";
        }
      case InterviewLanguage.kazakh:
        switch (this) {
          case InterviewType.behavioral: return "Тәжірибе, күшті жақтар, мақсаттар";
          case InterviewType.technical:  return "Код, архитектура, техникалық дағдылар";
          case InterviewType.mixed:      return "Мінез-құлық және техникалық сұрақтар";
        }
      default:
        switch (this) {
          case InterviewType.behavioral: return "Background, strengths, experience, goals";
          case InterviewType.technical:  return "Coding, system design, technical skills";
          case InterviewType.mixed:      return "Both behavioral & technical questions";
        }
    }
  }

  IconData get icon {
    switch (this) {
      case InterviewType.behavioral: return Icons.person_rounded;
      case InterviewType.technical:  return Icons.code_rounded;
      case InterviewType.mixed:      return Icons.shuffle_rounded;
    }
  }

  String get systemPromptHint {
    switch (this) {
      case InterviewType.behavioral:
        return "Focus ONLY on behavioral questions: background, strengths, weaknesses, motivation, teamwork, leadership, career goals.";
      case InterviewType.technical:
        return "Focus ONLY on technical questions: coding problems, system design, algorithms, architecture, tools relevant to the role.";
      case InterviewType.mixed:
        return "Mix of behavioral and technical questions. Start with background, then move to technical skills.";
    }
  }
}

// ─── EXPERIENCE LEVEL ───
extension ExperienceLevelExt on ExperienceLevel {
  String get label => switch (this) {
    ExperienceLevel.intern  => "Intern",
    ExperienceLevel.junior  => "Junior",
    ExperienceLevel.middle  => "Middle",
    ExperienceLevel.senior  => "Senior",
  };

  String get emoji => switch (this) {
    ExperienceLevel.intern  => "🌱",
    ExperienceLevel.junior  => "🚀",
    ExperienceLevel.middle  => "⚡",
    ExperienceLevel.senior  => "🔥",
  };

  Color get color => switch (this) {
    ExperienceLevel.intern  => const Color(0xFF22C55E),
    ExperienceLevel.junior  => const Color(0xFF3B82F6),
    ExperienceLevel.middle  => const Color(0xFFF59E0B),
    ExperienceLevel.senior  => const Color(0xFFEF4444),
  };

  String get systemPromptHint => switch (this) {
    ExperienceLevel.intern  =>
      "Candidate is an INTERN (student/no experience). Ask very basic questions. Focus on learning potential, motivation, basic concepts. Do NOT ask about years of experience or complex architecture.",
    ExperienceLevel.junior  =>
      "Candidate is JUNIOR (0-2 years). Ask foundational questions. Basic algorithms, simple system design, core language features. Expect some gaps in knowledge.",
    ExperienceLevel.middle  =>
      "Candidate is MIDDLE (2-5 years). Ask intermediate questions. System design, code quality, debugging, team collaboration, project ownership.",
    ExperienceLevel.senior  =>
      "Candidate is SENIOR (5+ years). Ask advanced questions. Architecture decisions, trade-offs, mentoring, complex system design, technical leadership.",
  };
}

// ─── LANGUAGE ───
extension InterviewLanguageExt on InterviewLanguage {
  String get flag => switch (this) {
    InterviewLanguage.english => "🇬🇧",
    InterviewLanguage.russian => "🇷🇺",
    InterviewLanguage.kazakh  => "🇰🇿",
  };

  String get name => switch (this) {
    InterviewLanguage.english => "English",
    InterviewLanguage.russian => "Русский",
    InterviewLanguage.kazakh  => "Қазақша",
  };

  String get whisperCode => switch (this) {
    InterviewLanguage.english => "en",
    InterviewLanguage.russian => "ru",
    InterviewLanguage.kazakh  => "kk",
  };

  String get systemLanguageInstruction => switch (this) {
    InterviewLanguage.english => "Conduct the entire interview in English.",
    InterviewLanguage.russian => "Проводи всё интервью на русском языке. Все вопросы и ответы — только на русском.",
    InterviewLanguage.kazakh  => "Барлық сұхбатты қазақ тілінде жүргіз. Барлық сұрақтар мен жауаптар тек қазақша болсын.",
  };

  String get startButton => switch (this) {
    InterviewLanguage.english => "Start Interview",
    InterviewLanguage.russian => "Начать интервью",
    InterviewLanguage.kazakh  => "Сұхбатты бастау",
  };

  String get rolePlaceholder => switch (this) {
    InterviewLanguage.english => "Job role...",
    InterviewLanguage.russian => "Должность...",
    InterviewLanguage.kazakh  => "Лауазым...",
  };

  String get jdPlaceholder => switch (this) {
    InterviewLanguage.english => "Paste job description here...",
    InterviewLanguage.russian => "Вставьте описание вакансии сюда...",
    InterviewLanguage.kazakh  => "Жұмыс сипаттамасын осюда қойыңыз...",
  };

  String get byRoleLabel => switch (this) {
    InterviewLanguage.english => "By Role",
    InterviewLanguage.russian => "По должности",
    InterviewLanguage.kazakh  => "Лауазым бойынша",
  };

  String get byJdLabel => switch (this) {
    InterviewLanguage.english => "By Job Description",
    InterviewLanguage.russian => "По вакансии",
    InterviewLanguage.kazakh  => "Вакансия бойынша",
  };

  String get interviewTypeLabel => switch (this) {
    InterviewLanguage.english => "Interview Type",
    InterviewLanguage.russian => "Тип интервью",
    InterviewLanguage.kazakh  => "Сұхбат түрі",
  };

  String get levelLabel => switch (this) {
    InterviewLanguage.english => "Experience Level",
    InterviewLanguage.russian => "Уровень",
    InterviewLanguage.kazakh  => "Деңгей",
  };

  String get questionsLabel => switch (this) {
    InterviewLanguage.english => "Number of Questions",
    InterviewLanguage.russian => "Количество вопросов",
    InterviewLanguage.kazakh  => "Сұрақтар саны",
  };

  String get languageLabel => switch (this) {
    InterviewLanguage.english => "Interview Language",
    InterviewLanguage.russian => "Язык интервью",
    InterviewLanguage.kazakh  => "Сұхбат тілі",
  };

  String get questionsWord => switch (this) {
    InterviewLanguage.english => "questions",
    InterviewLanguage.russian => "вопросов",
    InterviewLanguage.kazakh  => "сұрақ",
  };

  String get langNote => switch (this) {
    InterviewLanguage.english => "This only changes the interview language",
    InterviewLanguage.russian => "Это меняет только язык интервью",
    InterviewLanguage.kazakh  => "Бұл тек сұхбат тілін өзгертеді",
  };
}

// ─── helper: map app locale → InterviewLanguage ───────────────────────────────
InterviewLanguage _appLocaleToInterviewLanguage(String localeCode) {
  switch (localeCode) {
    case 'ru': return InterviewLanguage.russian;
    case 'kk': return InterviewLanguage.kazakh;
    default:   return InterviewLanguage.english;
  }
}

// ─── WIDGET ───
class IntroUI extends StatefulWidget {
  final void Function(
    String jobRole,
    InterviewType type,
    int questionCount,
    InterviewLanguage language,
    ExperienceLevel level,
    String? jobDescription,
  ) onStart;

  const IntroUI({super.key, required this.onStart});

  @override
  State<IntroUI> createState() => _IntroUIState();
}

class _IntroUIState extends State<IntroUI> {
  final _roleController = TextEditingController(text: 'Software Engineer');
  final _jdController   = TextEditingController();

  InterviewType     _selectedType     = InterviewType.mixed;
  // Will be set in didChangeDependencies from the app locale
  InterviewLanguage? _selectedLanguage;
  ExperienceLevel   _selectedLevel    = ExperienceLevel.junior;
  int  _questionCount = 7;
  bool _useJd         = false;

  // ── On first build, sync interview language with app locale ──────────────
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedLanguage == null) {
      final appLocale = Localizations.localeOf(context).languageCode;
      _selectedLanguage = _appLocaleToInterviewLanguage(appLocale);
      // Update role preset to match language
      _roleController.text = _presets(_selectedLanguage!)[0];
    }
  }

  List<String> _presets(InterviewLanguage lang) => switch (lang) {
    InterviewLanguage.russian => ['Разработчик ПО', 'Продакт-менеджер', 'Дата-сайентист', 'UX дизайнер', 'DevOps инженер'],
    InterviewLanguage.kazakh  => ['Бағдарламашы', 'Өнім менеджері', 'Деректер ғалымы', 'UX дизайнер', 'DevOps инженер'],
    _                         => ['Software Engineer', 'Product Manager', 'Data Scientist', 'UX Designer', 'DevOps Engineer'],
  };

  @override
  void dispose() {
    _roleController.dispose();
    _jdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fallback while not yet initialized
    final lang = _selectedLanguage ?? InterviewLanguage.english;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(),
            const SizedBox(height: 16),
            Text("AI Interview", style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 22),

            // ── LANGUAGE ──
            _sectionLabel(lang.languageLabel),
            const SizedBox(height: 6),
            // subtle note that this doesn't affect app language
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 13, color: Colors.white.withValues(alpha: 0.35)),
                const SizedBox(width: 5),
                Text(
                  lang.langNote,
                  style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.35)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: InterviewLanguage.values.map((l) {
                final isSelected = lang == l;
                final isLast = l == InterviewLanguage.kazakh;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedLanguage = l;
                      _roleController.text = _presets(l)[0];
                    }),
                    child: Container(
                      margin: EdgeInsets.only(right: isLast ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF7C5CFF).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? const Color(0xFF7C5CFF) : Colors.white.withValues(alpha: 0.12), width: isSelected ? 2 : 1),
                      ),
                      child: Column(
                        children: [
                          Text(l.flag, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(l.name, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // ── MODE SWITCHER ──
            if (_selectedType != InterviewType.behavioral) Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _modeTab(lang.byRoleLabel, Icons.work_outline_rounded, false),
                  _modeTab(lang.byJdLabel, Icons.description_outlined, true),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── BY ROLE MODE ──
            if (!_useJd) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _roleController,
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: lang.rolePlaceholder,
                    hintStyle: GoogleFonts.montserrat(color: Colors.white.withValues(alpha: 0.4)),
                    prefixIcon: Icon(Icons.work_outline_rounded, color: Colors.white.withValues(alpha: 0.6), size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _presets(lang).map((role) => GestureDetector(
                  onTap: () => setState(() => _roleController.text = role),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Text(role, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.85))),
                  ),
                )).toList(),
              ),

              const SizedBox(height: 18),

              _sectionLabel(lang.levelLabel),
              const SizedBox(height: 10),
              Row(
                children: ExperienceLevel.values.map((level) {
                  final isSelected = _selectedLevel == level;
                  final isLast = level == ExperienceLevel.senior;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedLevel = level),
                      child: Container(
                        margin: EdgeInsets.only(right: isLast ? 0 : 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? level.color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? level.color : Colors.white.withValues(alpha: 0.12),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(level.emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(level.label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w800, color: isSelected ? level.color : Colors.white.withValues(alpha: 0.7))),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // ── BY JD MODE ──
            if (_useJd) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _jdController,
                  maxLines: 7,
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13, height: 1.5),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: lang.jdPlaceholder,
                    hintStyle: GoogleFonts.montserrat(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      lang == InterviewLanguage.russian
                          ? "AI проанализирует вакансию и задаст релевантные вопросы"
                          : lang == InterviewLanguage.kazakh
                              ? "AI вакансияны талдап, тиісті сұрақтар қояды"
                              : "AI will analyze the job posting and ask relevant questions",
                      style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),

            // ── INTERVIEW TYPE ──
            _sectionLabel(lang.interviewTypeLabel),
            const SizedBox(height: 10),
            ...InterviewType.values.map((type) => GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == type ? const Color(0xFF7C5CFF).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _selectedType == type ? const Color(0xFF7C5CFF) : Colors.white.withValues(alpha: 0.12),
                    width: _selectedType == type ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(type.icon, color: _selectedType == type ? Colors.white : Colors.white.withValues(alpha: 0.5), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(type.label(lang), style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text(type.description(lang), style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.55))),
                        ],
                      ),
                    ),
                    if (_selectedType == type)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF7C5CFF), size: 20),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 16),

            // ── QUESTIONS COUNT ──
            _sectionLabel(lang.questionsLabel),
            const SizedBox(height: 10),
            Row(
              children: [5, 7, 10].map((count) {
                final isLast = count == 10;
                final isSelected = _questionCount == count;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _questionCount = count),
                    child: Container(
                      margin: EdgeInsets.only(right: isLast ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF7C5CFF).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF7C5CFF) : Colors.white.withValues(alpha: 0.12),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('$count', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                          Text(lang.questionsWord, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55))),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (_useJd) {
                    final jd = _jdController.text.trim();
                    if (jd.isEmpty) return;
                    widget.onStart('Custom Role', _selectedType, _questionCount, lang, _selectedLevel, jd);
                  } else {
                    final role = _roleController.text.trim();
                    if (role.isEmpty) return;
                    widget.onStart(role, _selectedType, _questionCount, lang, _selectedLevel, null);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C5CFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(lang.startButton, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeTab(String label, IconData icon, bool isJd) {
    final selected = _useJd == isJd;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _useJd = isJd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF7C5CFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: selected ? Colors.white : Colors.white.withValues(alpha: 0.45)),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w800, color: selected ? Colors.white : Colors.white.withValues(alpha: 0.45))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.7))),
  );

  Widget _buildAvatar() => Container(
    width: 120, height: 120,
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
        child: Center(
          child: Image.asset("assets/images/aipenguin.png", width: 95, height: 95, fit: BoxFit.contain),
        ),
      ),
    ),
  );
}