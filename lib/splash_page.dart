import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {

  late AnimationController _pingvinController;
  late AnimationController _textController;
  late AnimationController _dotsController;
  late AnimationController _glowController;
  late AnimationController _starsController;

  late Animation<double> _pingvinScale;
  late Animation<double> _pingvinOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    
    _pingvinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pingvinScale = CurvedAnimation(
      parent: _pingvinController,
      curve: Curves.elasticOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    _pingvinOpacity = CurvedAnimation(
      parent: _pingvinController,
      curve: const Interval(0.0, 0.4),
    ).drive(Tween(begin: 0.0, end: 1.0));

    
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textSlide = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: const Offset(0, 0.5), end: Offset.zero));
    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));

    
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

   
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glow = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ).drive(Tween(begin: 0.3, end: 1.0));

    
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  Future<void> _startSequence() async {
   
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    
    _pingvinController.forward();


    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _textController.forward();

   
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

  
    _navigate();
  }

  

  void _navigate() {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    Navigator.of(context).pushReplacementNamed(
      user != null ? '/MainShell' : '/FirstPage',
    );
  }

  @override
  void dispose() {
    _pingvinController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    _glowController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1A),
      body: Stack(
        children: [
          _buildStarryBackground(),

          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _glow,
                  builder: (_, child) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C5CFF).withValues(alpha: _glow.value * 0.4),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: _glow.value * 0.2),
                          blurRadius: 120,
                          spreadRadius: 40,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                  child: ScaleTransition(
                    scale: _pingvinScale,
                    child: FadeTransition(
                      opacity: _pingvinOpacity,
                      child: Image.asset(
                        'assets/images/aipenguin.png',
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Dayind',
                                style: GoogleFonts.montserrat(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'AI',
                                style: GoogleFonts.montserrat(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: [Color(0xFF7C5CFF), Color(0xFF3B82F6)],
                                    ).createShader(const Rect.fromLTWH(0, 0, 80, 40)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your AI Career Coach',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.45),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                
                FadeTransition(
                  opacity: _textOpacity,
                  child: _buildLoadingDots(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = (_dotsController.value - delay).clamp(0.0, 1.0);
            final opacity = sin(t * pi).clamp(0.2, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C5CFF).withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStarryBackground() {
    return AnimatedBuilder(
      animation: _starsController,
      builder: (_, __) => CustomPaint(
        painter: _StarsPainter(_starsController.value),
        size: Size.infinite,
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double progress;
  static final List<_Star> _stars = List.generate(80, (i) {
    final rand = Random(i);
    return _Star(
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      size: rand.nextDouble() * 2 + 0.5,
      speed: rand.nextDouble() * 0.3 + 0.05,
      opacity: rand.nextDouble() * 0.6 + 0.2,
    );
  });

  _StarsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in _stars) {
      final twinkle = (sin((progress * star.speed * 2 * pi * 10) + star.x * 10) + 1) / 2;
      final opacity = (star.opacity * (0.4 + twinkle * 0.6)).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 0.5);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.progress != progress;
}

class _Star {
  final double x, y, size, speed, opacity;
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}