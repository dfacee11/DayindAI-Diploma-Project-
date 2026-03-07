class ResumeL10n {
  final String title;
  final String sectionPersonal, sectionSummary, sectionExperience, sectionEducation, sectionSkills;
  final String fieldName, fieldTitle, fieldEmail, fieldPhone, fieldLocation, fieldSummary;
  final String fieldCompany, fieldRole, fieldPeriod, fieldDesc;
  final String fieldInstitution, fieldDegree, fieldSkills, fieldLangs;
  final String addExperience, addEducation, optional, noExperience, noEducation;
  final String aiHint, generateButton;
  final String generating, generatingSub;
  final String readyTitle, readySub, downloadPdf, editResume;

  const ResumeL10n({
    required this.title,
    required this.sectionPersonal, required this.sectionSummary, required this.sectionExperience,
    required this.sectionEducation, required this.sectionSkills,
    required this.fieldName, required this.fieldTitle, required this.fieldEmail,
    required this.fieldPhone, required this.fieldLocation, required this.fieldSummary,
    required this.fieldCompany, required this.fieldRole, required this.fieldPeriod,
    required this.fieldDesc, required this.fieldInstitution, required this.fieldDegree,
    required this.fieldSkills, required this.fieldLangs,
    required this.addExperience, required this.addEducation, required this.optional,
    required this.noExperience, required this.noEducation,
    required this.aiHint, required this.generateButton,
    required this.generating, required this.generatingSub,
    required this.readyTitle, required this.readySub, required this.downloadPdf, required this.editResume,
  });

  static ResumeL10n of(String l) => switch (l) {
    'ru' => const ResumeL10n(
      title: 'Шаблоны резюме',
      sectionPersonal: 'ЛИЧНЫЕ ДАННЫЕ', sectionSummary: 'О СЕБЕ', sectionExperience: 'ОПЫТ РАБОТЫ',
      sectionEducation: 'ОБРАЗОВАНИЕ', sectionSkills: 'НАВЫКИ',
      fieldName: 'Полное имя', fieldTitle: 'Должность', fieldEmail: 'Email',
      fieldPhone: 'Телефон', fieldLocation: 'Город', fieldSummary: 'Пару слов о себе...',
      fieldCompany: 'Компания', fieldRole: 'Должность', fieldPeriod: 'Период (2022 — 2024)',
      fieldDesc: 'Опишите обязанности...', fieldInstitution: 'Учебное заведение',
      fieldDegree: 'Специальность / степень', fieldSkills: 'Навыки через запятую',
      fieldLangs: 'Казахский, Русский, Английский',
      addExperience: '+ Добавить место работы', addEducation: '+ Добавить образование', optional: '(необязательно)',
      noExperience: 'Нет опыта работы', noEducation: 'Нет высшего образования',
      aiHint: 'AI улучшит текст — сделает его профессиональнее для рекрутеров',
      generateButton: 'Создать резюме',
      generating: 'Улучшаем резюме...', generatingSub: 'Займёт около 3 секунд',
      readyTitle: 'Резюме готово!', readySub: 'AI улучшил текст — скачивай PDF',
      downloadPdf: 'Скачать PDF', editResume: 'Редактировать',
    ),
    'kk' => const ResumeL10n(
      title: 'Түйіндеме үлгілері',
      sectionPersonal: 'ЖЕКЕ ДЕРЕКТЕР', sectionSummary: 'ӨЗІ ТУРАЛЫ', sectionExperience: 'ЖҰМЫС ТӘЖІРИБЕСІ',
      sectionEducation: 'БІЛІМ', sectionSkills: 'ДАҒДЫЛАР',
      fieldName: 'Толық аты-жөні', fieldTitle: 'Лауазым', fieldEmail: 'Email',
      fieldPhone: 'Телефон', fieldLocation: 'Қала', fieldSummary: 'Өзіңіз туралы...',
      fieldCompany: 'Компания', fieldRole: 'Лауазым', fieldPeriod: 'Кезең (2022 — 2024)',
      fieldDesc: 'Міндеттерді сипаттаңыз...', fieldInstitution: 'Оқу орны',
      fieldDegree: 'Мамандық / дәреже', fieldSkills: 'Дағдыларды үтірмен',
      fieldLangs: 'Қазақша, Орысша, Ағылшынша',
      addExperience: '+ Жұмыс орны қосу', addEducation: '+ Білім қосу', optional: '(міндетті емес)',
      noExperience: 'Жұмыс тәжірибесі жоқ', noEducation: 'Жоғары білімі жоқ',
      aiHint: 'AI мәтініңді жақсартады — рекрутерлерге байқалатындай',
      generateButton: 'Түйіндеме жасау',
      generating: 'Түйіндемені жақсартуда...', generatingSub: 'Шамамен 3 секунд',
      readyTitle: 'Түйіндеме дайын!', readySub: 'AI мәтінді жақсартты — PDF жүктe',
      downloadPdf: 'PDF жүктеу', editResume: 'Өңдеу',
    ),
    _ => const ResumeL10n(
      title: 'Resume Templates',
      sectionPersonal: 'PERSONAL INFO', sectionSummary: 'ABOUT ME', sectionExperience: 'EXPERIENCE',
      sectionEducation: 'EDUCATION', sectionSkills: 'SKILLS',
      fieldName: 'Full Name', fieldTitle: 'Job Title', fieldEmail: 'Email',
      fieldPhone: 'Phone', fieldLocation: 'City', fieldSummary: 'A few words about yourself...',
      fieldCompany: 'Company', fieldRole: 'Position', fieldPeriod: 'Period (2022 — 2024)',
      fieldDesc: 'Describe your responsibilities...', fieldInstitution: 'Institution',
      fieldDegree: 'Degree / Specialty', fieldSkills: 'Skills separated by commas',
      fieldLangs: 'Kazakh, Russian, English',
      addExperience: '+ Add Experience', addEducation: '+ Add Education', optional: '(optional)',
      noExperience: 'No work experience', noEducation: 'No higher education',
      aiHint: 'AI rewrites your text to sound more professional to recruiters',
      generateButton: 'Generate Resume',
      generating: 'Improving your resume...', generatingSub: 'This takes about 3 seconds',
      readyTitle: 'Resume Ready!', readySub: 'AI improved your text — download PDF',
      downloadPdf: 'Download PDF', editResume: 'Edit',
    ),
  };
}