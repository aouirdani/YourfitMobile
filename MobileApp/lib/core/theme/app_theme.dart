import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// Your existing AppTheme class
class AppTheme {
  static const primaryColor = Color(0xFF6366F1);
  static const secondaryColor = Color(0xFF22D3EE);
  static const accentColor = Color(0xFF10B981);
  static const errorColor = Color(0xFFEF4444);
  static const backgroundColor = Color(0xFFF9FAFB);
  static const darkBackgroundColor = Color(0xFF111827);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: backgroundColor,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: darkBackgroundColor,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    scaffoldBackgroundColor: Color(0xFF0A0A0B), // Dark starfield background
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    ),
  );
}

void main() {
  runApp(FitnessAIApp());
}

class FitnessAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitnessAI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Use dark theme for this screen
      home: WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  List<Star> stars = [];
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _generateStars();
    _generateParticles();
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

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with particle effect
                        Container(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow effect
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.blue.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              // Logo icon with your theme color
                              Icon(
                                Icons.fitness_center,
                                size: 60,
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),

                        // App name with gradient using your theme colors
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.secondaryColor
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'FitnessAI',
                            style: GoogleFonts.inter(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tagline with Inter font
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
                        SizedBox(height: 60),

                        // Get Started Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              // Add navigation logic here
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Welcome to FitnessAI!'),
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
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
                        SizedBox(height: 24),

                        // Login link with theme colors and Inter font
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
                                // Add login navigation logic here
                              },
                              child: Text(
                                'Log in',
                                style: GoogleFonts.inter(
                                  color: AppTheme.secondaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final paint = Paint()..color = AppTheme.secondaryColor.withOpacity(0.6);

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

      paint.color = AppTheme.secondaryColor.withOpacity(particle.opacity * 0.8);
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
