import 'package:flutter/material.dart';

class TipsData {
  static List<Map<String, dynamic>> getTips(String langCode) {
    switch (langCode) {
      case 'ru':
        return [
          {
            'title': 'Совет для интервью',
            'text': 'Перед ответом сделайте паузу 2 секунды. Это звучит уверенно, а не нервно.',
            'icon': Icons.mic_rounded,
          },
          {
            'title': 'Совет по поиску работы',
            'text': 'Откликайтесь через LinkedIn и пишите короткое сообщение рекрутеру — это удваивает шансы.',
            'icon': Icons.work_outline_rounded,
          },
          {
            'title': 'Совет по резюме',
            'text': 'Замените "Отвечал за" на сильные глаголы: Создал, Улучшил, Внедрил, Автоматизировал.',
            'icon': Icons.description_outlined,
          },
          {
            'title': 'Совет по портфолио',
            'text': 'Поставьте лучший проект первым. Рекрутеры смотрят только первые 20 секунд.',
            'icon': Icons.folder_open_rounded,
          },
          {
            'title': 'Совет для интервью',
            'text': 'Используйте метод STAR: Ситуация → Задача → Действие → Результат. Коротко и чётко.',
            'icon': Icons.psychology_alt_rounded,
          },
        ];
      case 'kk':
        return [
          {
            'title': 'Сұхбат кеңесі',
            'text': 'Жауап бермес бұрын 2 секунд үн қатпаңыз. Бұл сенімді естіледі, жүйкелі емес.',
            'icon': Icons.mic_rounded,
          },
          {
            'title': 'Жұмыс іздеу кеңесі',
            'text': 'LinkedIn арқылы өтінім жіберіп, рекрутерге қысқа хабарлама жазыңыз — мүмкіндік екі есе артады.',
            'icon': Icons.work_outline_rounded,
          },
          {
            'title': 'Түйіндеме кеңесі',
            'text': '"Жауапты болдым" орнына күшті етістіктер қолданыңыз: Жасадым, Жақсарттым, Автоматтандырдым.',
            'icon': Icons.description_outlined,
          },
          {
            'title': 'Портфолио кеңесі',
            'text': 'Ең жақсы жобаңызды бірінші қойыңыз. Рекрутерлер тек алғашқы 20 секундқа қарайды.',
            'icon': Icons.folder_open_rounded,
          },
          {
            'title': 'Сұхбат кеңесі',
            'text': 'STAR әдісін қолданыңыз: Жағдай → Тапсырма → Әрекет → Нәтиже. Қысқа және нақты.',
            'icon': Icons.psychology_alt_rounded,
          },
        ];
      default:
        return [
          {
            'title': 'Interview tip',
            'text': 'Before answering, pause 2 seconds. It makes you sound confident, not nervous.',
            'icon': Icons.mic_rounded,
          },
          {
            'title': 'Job search tip',
            'text': 'Apply through LinkedIn + also send a short message to the recruiter. It doubles your chances.',
            'icon': Icons.work_outline_rounded,
          },
          {
            'title': 'Resume tip',
            'text': 'Replace "Responsible for" with strong verbs: Built, Improved, Delivered, Automated.',
            'icon': Icons.description_outlined,
          },
          {
            'title': 'Portfolio tip',
            'text': 'Put your best project first. Recruiters often look only at the first 20 seconds.',
            'icon': Icons.folder_open_rounded,
          },
          {
            'title': 'Interview tip',
            'text': 'Use the STAR method: Situation → Task → Action → Result. Keep it short and clear.',
            'icon': Icons.psychology_alt_rounded,
          },
        ];
    }
  }
}