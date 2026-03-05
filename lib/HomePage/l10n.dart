import 'package:flutter/material.dart';


const List<Locale> appSupportedLocales = [
  Locale('en'),
  Locale('ru'),
  Locale('kk'),
];

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _delegate = _AppLocalizationsDelegate();
  static LocalizationsDelegate<AppLocalizations> get delegate => _delegate;

  

  static final Map<String, Map<String, String>> _localizedStrings = {
    
    'greeting_hi': {
      'en': 'Hi ',
      'ru': 'Привет ',
      'kk': 'Сәлем ',
    },
    'greeting_subtitle': {
      'en': 'Choose an AI tool to continue',
      'ru': 'Выберите AI-инструмент для продолжения',
      'kk': 'Жалғастыру үшін AI құралын таңдаңыз',
    },
    'section_ai_tools': {
      'en': 'AI Tools',
      'ru': 'AI Инструменты',
      'kk': 'AI Құралдары',
    },
    'section_last_interview': {
      'en': 'Last Interview',
      'ru': 'Последнее интервью',
      'kk': 'Соңғы сұхбат',
    },
    'section_tips': {
      'en': 'Tips for you',
      'ru': 'Советы для вас',
      'kk': 'Сізге кеңестер',
    },

    
    'tool_interview_title': {
      'en': 'AI Interview',
      'ru': 'AI Интервью',
      'kk': 'AI Сұхбат',
    },
    'tool_interview_desc': {
      'en': 'Practice interview with AI + get feedback.',
      'ru': 'Пройдите интервью с AI и получите обратную связь.',
      'kk': 'AI-мен сұхбат өткізіп, кері байланыс алыңыз.',
    },
    'tool_interview_btn': {
      'en': 'Start Interview',
      'ru': 'Начать интервью',
      'kk': 'Сұхбатты бастау',
    },

    'tool_resume_analyzer_title': {
      'en': 'Resume Analyzer',
      'ru': 'Анализ резюме',
      'kk': 'Түйіндемені талдау',
    },
    'tool_resume_analyzer_desc': {
      'en': 'Upload resume and get AI review + tips.',
      'ru': 'Загрузите резюме и получите AI-анализ + советы.',
      'kk': 'Түйіндемені жүктеп, AI талдауы мен кеңестер алыңыз.',
    },
    'tool_resume_analyzer_btn': {
      'en': 'Analyze Resume',
      'ru': 'Анализировать',
      'kk': 'Талдау',
    },

    'tool_resume_matching_title': {
      'en': 'Resume Matching',
      'ru': 'Совпадение резюме',
      'kk': 'Түйіндемені сәйкестендіру',
    },
    'tool_resume_matching_desc': {
      'en': 'Check how well your resume matches a job.',
      'ru': 'Проверьте, насколько ваше резюме соответствует вакансии.',
      'kk': 'Түйіндемеңіздің жұмысқа қаншалықты сәйкес келетінін тексеріңіз.',
    },
    'tool_resume_matching_btn': {
      'en': 'Match Now',
      'ru': 'Проверить',
      'kk': 'Тексеру',
    },

    // ── AUTH ───────────────────────────────────────────────────────────────
    'logout': {
      'en': 'Logout',
      'ru': 'Выйти',
      'kk': 'Шығу',
    },

    // ── GENERAL ────────────────────────────────────────────────────────────
    'user_fallback': {
      'en': 'User',
      'ru': 'Пользователь',
      'kk': 'Пайдаланушы',
    },
  };


  String translate(String key) {
    final langCode = locale.languageCode;
    return _localizedStrings[key]?[langCode] ??
        _localizedStrings[key]?['en'] ??
        key;
  }

  
  String get greetingHi             => translate('greeting_hi');
  String get greetingSubtitle       => translate('greeting_subtitle');
  String get sectionAiTools         => translate('section_ai_tools');
  String get sectionLastInterview   => translate('section_last_interview');
  String get sectionTips            => translate('section_tips');

  String get toolInterviewTitle     => translate('tool_interview_title');
  String get toolInterviewDesc      => translate('tool_interview_desc');
  String get toolInterviewBtn       => translate('tool_interview_btn');

  String get toolAnalyzerTitle      => translate('tool_resume_analyzer_title');
  String get toolAnalyzerDesc       => translate('tool_resume_analyzer_desc');
  String get toolAnalyzerBtn        => translate('tool_resume_analyzer_btn');

  String get toolMatchingTitle      => translate('tool_resume_matching_title');
  String get toolMatchingDesc       => translate('tool_resume_matching_desc');
  String get toolMatchingBtn        => translate('tool_resume_matching_btn');

  String get logout                 => translate('logout');
  String get userFallback           => translate('user_fallback');
}


class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ru', 'kk'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}