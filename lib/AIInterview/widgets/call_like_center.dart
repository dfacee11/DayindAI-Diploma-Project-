import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallLikeCenter extends StatefulWidget {
  final bool aiIsSpeaking;

  const CallLikeCenter({super.key, required this.aiIsSpeaking});

  @override
  State<CallLikeCenter> createState() => _CallLikeCenterState();
}

class _CallLikeCenterState extends State<CallLikeCenter>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _ringAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Основная пульсация аватара
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Расходящееся кольцо
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _ringAnimation = Tween<double>(begin: 0.85, end: 1.3).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    if (widget.aiIsSpeaking) _startAnimations();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _ringController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _pulseController.animateTo(0);
    _ringController.stop();
    _ringController.reset();
  }

  @override
  void didUpdateWidget(CallLikeCenter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.aiIsSpeaking && !oldWidget.aiIsSpeaking) {
      _startAnimations();
    } else if (!widget.aiIsSpeaking && oldWidget.aiIsSpeaking) {
      _stopAnimations();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [

                // ── Расходящееся кольцо (только когда говорит) ──
                if (widget.aiIsSpeaking)
                  AnimatedBuilder(
                    animation: _ringController,
                    builder: (_, __) => Transform.scale(
                      scale: _ringAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF7C5CFF),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Второе кольцо с задержкой ──
                if (widget.aiIsSpeaking)
                  AnimatedBuilder(
                    animation: _ringController,
                    builder: (_, __) {
                      final delayed = (_ringController.value + 0.5) % 1.0;
                      final scale = 0.85 + delayed * 0.45;
                      final opacity = (0.5 - delayed * 0.5).clamp(0.0, 0.5);
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF7C5CFF),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // ── Основной круг с пингвином ──
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, child) => Transform.scale(
                    scale: widget.aiIsSpeaking ? _scaleAnimation.value : 1.0,
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.aiIsSpeaking
                          ? const Color(0xFF7C5CFF).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: widget.aiIsSpeaking
                            ? const Color(0xFF7C5CFF).withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.10),
                        width: widget.aiIsSpeaking ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/images/aipenguin.png",
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              widget.aiIsSpeaking ? "Speaking..." : "Waiting...",
              key: ValueKey(widget.aiIsSpeaking),
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Tap transcript icon if you want to read.",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.70),
            ),
          ),
        ],
      ),
    );
  }
}