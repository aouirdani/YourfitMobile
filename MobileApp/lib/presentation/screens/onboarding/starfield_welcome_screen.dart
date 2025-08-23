import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class StarfieldWelcomeScreen extends ConsumerStatefulWidget {
  const StarfieldWelcomeScreen({super.key});

  @override
  ConsumerState<StarfieldWelcomeScreen> createState() =>
      _StarfieldWelcomeScreenState();
}

class _StarfieldWelcomeScreenState extends ConsumerState<StarfieldWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late AnimationController _logoController;
  late AnimationController _runnerController;

  late Animation<double> _logoSlideAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _runnerBounceAnimation;
  late Animation<double> _runnerPulseAnimation;

  List<Star> stars = [];
  List<Particle> particles = [];
  List<EnergyParticle> energyParticles = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _runnerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    // Logo animations
    _logoSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _runnerBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
    ));

    _runnerPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _runnerController,
      curve: Curves.easeInOut,
    ));

    _generateStars();
    _generateParticles();
    _generateEnergyParticles();

    // Start logo animation
    _logoController.forward();
  }

  void _generateStars() {
    final random = math.Random();
    for (int i = 0; i < 100; i++) {
      stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        opacity: random.nextDouble() * 0.8 + 0.2,
        size: random.nextDouble() * 2 + 0.5,
      ));
    }
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        vx: (random.nextDouble() - 0.5) * 0.001,
        vy: (random.nextDouble() - 0.5) * 0.001,
        opacity: random.nextDouble() * 0.6 + 0.1,
        size: random.nextDouble() * 1.5 + 0.3,
      ));
    }
  }

  void _generateEnergyParticles() {
    final random = math.Random();
    for (int i = 0; i < 6; i++) {
      energyParticles.add(EnergyParticle(
        angle: (i * 60) * (math.pi / 180),
        distance: 120 + random.nextDouble() * 30,
        opacity: random.nextDouble() * 0.3 + 0.1,
        size: random.nextDouble() * 2 + 1,
        speed: random.nextDouble() * 0.01 + 0.005,
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    _logoController.dispose();
    _runnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0B),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Animated starfield background
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarfieldPainter(
                    stars: stars,
                    animationValue: _animationController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Animated particles for logo
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: particles,
                    animationValue: _particleController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                            [_logoController, _runnerController]),
                        builder: (context, child) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Professional YourFit Logo
                              Container(
                                width: 280,
                                height: 160,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Subtle energy particles
                                    CustomPaint(
                                      painter: EnergyParticlePainter(
                                        particles: energyParticles,
                                        animationValue: _runnerController.value,
                                        center: const Offset(140, 80),
                                      ),
                                      size: const Size(280, 160),
                                    ),

                                    // Main Logo Content
                                    Transform.scale(
                                      scale: _runnerBounceAnimation.value,
                                      child: Opacity(
                                        opacity: _logoFadeAnimation.value,
                                        child: CustomPaint(
                                          painter: YourFitLogoPainter(
                                            animationValue:
                                                _runnerController.value,
                                            slideAnimation:
                                                _logoSlideAnimation.value,
                                          ),
                                          size: const Size(280, 160),
                                        ),
                                      ),
                                    ),

                                    // Subtle glow effect
                                    if (_logoController.isCompleted)
                                      Transform.scale(
                                        scale: _runnerPulseAnimation.value,
                                        child: Container(
                                          width: 280,
                                          height: 160,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF6366F1)
                                                    .withOpacity(0.1),
                                                blurRadius: 30,
                                                spreadRadius: 5,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tagline
                          Text(
                            'Let AI be your personal trainer and reach your fitness goals faster',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              color: Colors.grey[300],
                              height: 1.4,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 60),

                          // Get Started Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                context.go('/signup');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: Text(
                                'GET STARTED',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[400],
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.go('/login');
                                },
                                child: Text(
                                  'Log in',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF22D3EE),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double opacity;
  final double size;

  Star({
    required this.x,
    required this.y,
    required this.opacity,
    required this.size,
  });
}

class Particle {
  double x;
  double y;
  final double vx;
  final double vy;
  final double opacity;
  final double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.opacity,
    required this.size,
  });
}

class EnergyParticle {
  double angle;
  final double distance;
  final double opacity;
  final double size;
  final double speed;

  EnergyParticle({
    required this.angle,
    required this.distance,
    required this.opacity,
    required this.size,
    required this.speed,
  });
}

class StarfieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarfieldPainter({required this.stars, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (final star in stars) {
      final x = star.x * size.width;
      final y = star.y * size.height;
      final opacity = (star.opacity *
              (0.5 +
                  0.5 * math.sin(animationValue * 2 * math.pi + star.x * 10)))
          .clamp(0.0, 1.0);

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(
        Offset(x, y),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      particle.x += particle.vx;
      particle.y += particle.vy;

      if (particle.x < 0) particle.x = 1;
      if (particle.x > 1) particle.x = 0;
      if (particle.y < 0) particle.y = 1;
      if (particle.y > 1) particle.y = 0;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      paint.color = const Color(0xFF22D3EE).withOpacity(particle.opacity * 0.8);
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class EnergyParticlePainter extends CustomPainter {
  final List<EnergyParticle> particles;
  final double animationValue;
  final Offset center;

  EnergyParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      particle.angle += particle.speed;

      final x = center.dx + math.cos(particle.angle) * particle.distance;
      final y = center.dy + math.sin(particle.angle) * particle.distance;

      final floatOffset =
          math.sin(animationValue * 2 * math.pi + particle.angle) * 10;

      // Create gradient effect
      final gradient = RadialGradient(
        colors: [
          const Color(0xFF6366F1).withOpacity(particle.opacity),
          const Color(0xFF22D3EE).withOpacity(particle.opacity * 0.5),
          Colors.transparent,
        ],
      );

      paint.shader = gradient.createShader(Rect.fromCircle(
        center: Offset(x, y + floatOffset),
        radius: particle.size,
      ));

      canvas.drawCircle(
        Offset(x, y + floatOffset),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class YourFitLogoPainter extends CustomPainter {
  final double animationValue;
  final double slideAnimation;

  YourFitLogoPainter({
    required this.animationValue,
    required this.slideAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Text style settings - bold and chunky like the original
    const yourTextStyle = TextStyle(
      fontSize: 52,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.5,
      height: 0.85,
    );

    const fitTextStyle = TextStyle(
      fontSize: 52,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.5,
      height: 0.85,
    );

    // Create text painters with white color like original
    final yourPainter = TextPainter(
      text: TextSpan(
        text: 'Your',
        style: yourTextStyle.copyWith(
          foreground: Paint()
            ..shader = const LinearGradient(
              colors: [Colors.white, Color(0xFFE5E7EB)],
            ).createShader(const Rect.fromLTWH(0, 0, 200, 60)),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    final fitPainter = TextPainter(
      text: TextSpan(
        text: 'Fit',
        style: fitTextStyle.copyWith(
          foreground: Paint()
            ..shader = const LinearGradient(
              colors: [Colors.white, Color(0xFFE5E7EB)],
            ).createShader(const Rect.fromLTWH(0, 0, 150, 60)),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    yourPainter.layout();
    fitPainter.layout();

    // Position text like in the original - stacked vertically
    final centerX = size.width / 2;
    final startY = (size.height / 2) - 40;

    // Animate "Your" sliding from left
    final yourX = centerX - (yourPainter.width / 2) + (slideAnimation * 0.3);
    yourPainter.paint(canvas, Offset(yourX, startY));

    // Animate "Fit" sliding from right, positioned below "Your"
    final fitX = centerX - (fitPainter.width / 2) - (slideAnimation * 0.3);
    final fitY = startY + yourPainter.height - 8; // Tight spacing
    fitPainter.paint(canvas, Offset(fitX, fitY));

    // Enhanced Runner Silhouette - positioned to the right like original
    final runnerCenterX = centerX + (fitPainter.width / 2) + 35;
    final runnerCenterY = startY + 25;

    // Subtle breathing animation
    final breathe = 1.0 + (math.sin(animationValue * 3 * math.pi) * 0.03);

    canvas.save();
    canvas.translate(runnerCenterX, runnerCenterY);
    canvas.scale(breathe * 1.2); // Slightly larger like original

    // Detailed female runner silhouette matching the original
    final runnerPath = Path();

    // Head with ponytail
    runnerPath
        .addOval(Rect.fromCircle(center: const Offset(-2, -20), radius: 5.5));

    // Ponytail flowing back
    runnerPath.moveTo(-8, -22);
    runnerPath.quadraticBezierTo(-15, -18, -18, -12);
    runnerPath.quadraticBezierTo(-16, -10, -12, -14);
    runnerPath.quadraticBezierTo(-8, -18, -5, -19);

    // Torso and arms
    runnerPath.moveTo(-2, -14);
    runnerPath.lineTo(-1, -5);
    runnerPath.lineTo(2, 8);

    // Right arm forward (bent)
    runnerPath.moveTo(1, -8);
    runnerPath.lineTo(8, -12);
    runnerPath.lineTo(12, -8);
    runnerPath.lineTo(14, -6);
    runnerPath.lineTo(10, -4);
    runnerPath.lineTo(6, -6);
    runnerPath.lineTo(3, -5);

    // Left arm back
    runnerPath.moveTo(-1, -6);
    runnerPath.lineTo(-8, -4);
    runnerPath.lineTo(-12, 0);
    runnerPath.lineTo(-10, 2);
    runnerPath.lineTo(-6, -1);
    runnerPath.lineTo(-2, -3);

    // Torso to hips
    runnerPath.moveTo(-2, 5);
    runnerPath.lineTo(-3, 12);
    runnerPath.lineTo(3, 12);
    runnerPath.lineTo(2, 5);

    // Right leg (forward, lifted)
    runnerPath.moveTo(2, 12);
    runnerPath.lineTo(8, 18);
    runnerPath.lineTo(14, 22);
    runnerPath.lineTo(18, 26);
    runnerPath.lineTo(22, 28);
    runnerPath.lineTo(20, 31);
    runnerPath.lineTo(16, 29);
    runnerPath.lineTo(12, 25);
    runnerPath.lineTo(6, 21);
    runnerPath.lineTo(0, 15);

    // Left leg (back, extended)
    runnerPath.moveTo(-3, 12);
    runnerPath.lineTo(-8, 16);
    runnerPath.lineTo(-14, 22);
    runnerPath.lineTo(-18, 28);
    runnerPath.lineTo(-22, 32);
    runnerPath.lineTo(-20, 35);
    runnerPath.lineTo(-16, 33);
    runnerPath.lineTo(-12, 29);
    runnerPath.lineTo(-8, 23);
    runnerPath.lineTo(-5, 17);
    runnerPath.lineTo(-1, 13);

    // Fill runner with white like original
    paint.shader = null;
    paint.color = Colors.white;
    canvas.drawPath(runnerPath, paint);

    // Add subtle dynamic glow
    paint.color = const Color(0xFF6366F1).withOpacity(0.2);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(runnerPath, paint);

    canvas.restore();

    // Add motion lines behind runner for dynamic effect
    if (slideAnimation >= 0) {
      canvas.save();
      canvas.translate(runnerCenterX - 40, runnerCenterY);

      final motionPaint = Paint()
        ..color = const Color(0xFF6366F1).withOpacity(0.3)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      // Animated motion lines
      final motionOffset = math.sin(animationValue * 6 * math.pi) * 5;

      canvas.drawLine(
        Offset(-20 + motionOffset, -5),
        Offset(-35 + motionOffset, -5),
        motionPaint,
      );
      canvas.drawLine(
        Offset(-18 + motionOffset, 0),
        Offset(-38 + motionOffset, 0),
        motionPaint,
      );
      canvas.drawLine(
        Offset(-22 + motionOffset, 5),
        Offset(-32 + motionOffset, 5),
        motionPaint,
      );

      canvas.restore();
    }

    // Subtle shimmer effect across the entire logo
    if (slideAnimation >= 0) {
      final shimmerPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.15),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(
          -size.width + (animationValue * size.width * 2),
          0,
          size.width,
          size.height,
        ));

      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), shimmerPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
