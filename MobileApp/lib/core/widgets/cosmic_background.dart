import 'package:flutter/material.dart';
import 'dart:math' as math;

class CosmicBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;
  final int starCount;
  final Color starColor;
  final Color particleColor;
  final double intensity; // 0.0 to 1.0

  const CosmicBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.starCount = 80,
    this.starColor = Colors.white,
    this.particleColor = const Color(0xFF22D3EE),
    this.intensity = 1.0,
  });

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _particleController;
  List<CosmicStar> stars = [];
  List<CosmicParticle> particles = [];

  @override
  void initState() {
    super.initState();

    _starController = AnimationController(
      duration: Duration(seconds: (4 / widget.intensity).round()),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: Duration(seconds: (8 / widget.intensity).round()),
      vsync: this,
    )..repeat();

    _generateStars();
    if (widget.showParticles) {
      _generateParticles();
    }
  }

  void _generateStars() {
    final random = math.Random();
    stars.clear();
    for (int i = 0; i < widget.starCount; i++) {
      stars.add(CosmicStar(
        x: random.nextDouble(),
        y: random.nextDouble(),
        opacity: random.nextDouble() * 0.7 + 0.3,
        size: random.nextDouble() * 2 + 0.5,
        twinkleSpeed: random.nextDouble() * 2 + 1,
      ));
    }
  }

  void _generateParticles() {
    final random = math.Random();
    particles.clear();
    final particleCount = (40 * widget.intensity).round();
    for (int i = 0; i < particleCount; i++) {
      particles.add(CosmicParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        vx: (random.nextDouble() - 0.5) * 0.001 * widget.intensity,
        vy: (random.nextDouble() - 0.5) * 0.001 * widget.intensity,
        opacity: random.nextDouble() * 0.6 + 0.2,
        size: random.nextDouble() * 1.5 + 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0B),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0A0A0B),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated stars
          AnimatedBuilder(
            animation: _starController,
            builder: (context, child) {
              return CustomPaint(
                painter: CosmicStarPainter(
                  stars: stars,
                  animationValue: _starController.value,
                  starColor: widget.starColor,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Animated particles (if enabled)
          if (widget.showParticles)
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: CosmicParticlePainter(
                    particles: particles,
                    animationValue: _particleController.value,
                    particleColor: widget.particleColor,
                  ),
                  size: Size.infinite,
                );
              },
            ),

          // Main content
          widget.child,
        ],
      ),
    );
  }
}

class CosmicStar {
  final double x;
  final double y;
  final double opacity;
  final double size;
  final double twinkleSpeed;

  CosmicStar({
    required this.x,
    required this.y,
    required this.opacity,
    required this.size,
    required this.twinkleSpeed,
  });
}

class CosmicParticle {
  double x;
  double y;
  final double vx;
  final double vy;
  final double opacity;
  final double size;

  CosmicParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.opacity,
    required this.size,
  });
}

class CosmicStarPainter extends CustomPainter {
  final List<CosmicStar> stars;
  final double animationValue;
  final Color starColor;

  CosmicStarPainter({
    required this.stars,
    required this.animationValue,
    required this.starColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final star in stars) {
      final x = star.x * size.width;
      final y = star.y * size.height;
      final twinkle =
          math.sin(animationValue * 2 * math.pi * star.twinkleSpeed);
      final opacity = (star.opacity * (0.4 + 0.6 * twinkle)).clamp(0.0, 1.0);

      paint.color = starColor.withOpacity(opacity);

      // Draw star with slight glow
      canvas.drawCircle(Offset(x, y), star.size, paint);

      // Add subtle glow for larger stars
      if (star.size > 1.5) {
        paint.color = starColor.withOpacity(opacity * 0.3);
        canvas.drawCircle(Offset(x, y), star.size * 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CosmicParticlePainter extends CustomPainter {
  final List<CosmicParticle> particles;
  final double animationValue;
  final Color particleColor;

  CosmicParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      // Update particle position
      particle.x += particle.vx;
      particle.y += particle.vy;

      // Wrap around screen
      if (particle.x < 0) particle.x = 1;
      if (particle.x > 1) particle.x = 0;
      if (particle.y < 0) particle.y = 1;
      if (particle.y > 1) particle.y = 0;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      // Main particle
      paint.color = particleColor.withOpacity(particle.opacity);
      canvas.drawCircle(Offset(x, y), particle.size, paint);

      // Subtle glow
      paint.color = particleColor.withOpacity(particle.opacity * 0.3);
      canvas.drawCircle(Offset(x, y), particle.size * 2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Cosmic AppBar for consistent styling
class CosmicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const CosmicAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leading,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1).withOpacity(0.1),
              const Color(0xFF22D3EE).withOpacity(0.1),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Cosmic Card for consistent container styling
class CosmicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const CosmicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
