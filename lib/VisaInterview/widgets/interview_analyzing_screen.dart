import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InterviewAnalyzingScreen extends StatefulWidget {
  final String jobRole;
  final String language; // 'en', 'ru', 'kk'

  const InterviewAnalyzingScreen({
    super.key,
    required this.jobRole,
    required this.language,
  });

  @override
  State<InterviewAnalyzingScreen> createState() => _InterviewAnalyzingScreenState();
}

class _InterviewAnalyzingScreenState extends State<InterviewAnalyzingScreen>
    with TickerProviderStateMixin {

  late AnimationController _pulseController;

  late Animation<double> _pulseAnimation;

  int _currentStep = 0;
  Timer? _stepTimer;

  List<String> get _steps => switch (widget.language) {
    'ru' => [
      'Обрабатываю ваши ответы...',
      'Оцениваю коммуникацию...',
      'Анализирую технические знания...',
      'Формирую персональные советы...',
      'Готовлю финальный отчёт...',
    ],
    'kk' => [
      'Жауаптарыңызды өңдеп жатырмын...',
      'Коммуникацияны бағалап жатырмын...',
      'Техникалық білімді талдап жатырмын...',
      'Жеке кеңестер дайындап жатырмын...',
      'Қорытынды есепті жасап жатырмын...',
    ],
    _ => [
      'Processing your answers...',
      'Evaluating communication skills...',
      'Analyzing technical knowledge...',
      'Crafting personalized tips...',
      'Preparing your final report...',
    ],
  };

  String get _title => switch (widget.language) {
    'ru' => 'Анализирую интервью',
    'kk' => 'Сұхбатты талдап жатырмын',
    _ => 'Analyzing Interview',
  };

  String get _subtitle => switch (widget.language) {
    'ru' => 'AI изучает ваши ответы\nЭто займёт ~15 секунд',
    'kk' => 'AI жауаптарыңызды зерттеп жатыр\nБұл ~15 секунд алады',
    _ => 'AI is reviewing your answers\nThis takes ~15 seconds',
  };

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Псевдо-прогресс — меняем шаги каждые ~2.5 сек
    _stepTimer = Timer.periodic(const Duration(milliseconds: 2500), (t) {
      if (!mounted) return;
      setState(() {
        if (_currentStep < _steps.length - 1) _currentStep++;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // ── ПУЛЬСИРУЮЩИЙ АВАТАР ──
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7C5CFF).withValues(alpha: 0.4),
                        const Color(0xFF7C5CFF).withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF7C5CFF).withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/aipenguin.png',
                      width: 80, height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── ЗАГОЛОВОК ──
              Text(
                _title,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.55),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 40),

              // ── ПРОГРЕСС БАР ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (_, value, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(value * 100).toInt()}%',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF7C5CFF),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── СПИСОК ШАГОВ ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: _steps.asMap().entries.map((e) {
                    final isDone    = e.key < _currentStep;
                    final isCurrent = e.key == _currentStep;
                    

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          // Иконка
                          SizedBox(
                            width: 24, height: 24,
                            child: isDone
                                ? const Icon(Icons.check_circle_rounded,
                                    color: Color(0xFF22C55E), size: 20)
                                : isCurrent
                                    ? SizedBox(
                                        width: 18, height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: const AlwaysStoppedAnimation(Color(0xFF7C5CFF)),
                                        ),
                                      )
                                    : Icon(Icons.circle_outlined,
                                        color: Colors.white.withValues(alpha: 0.2), size: 20),
                          ),
                          const SizedBox(width: 12),
                          // Текст
                          Expanded(
                            child: Text(
                              e.value,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                color: isDone
                                    ? const Color(0xFF22C55E)
                                    : isCurrent
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}