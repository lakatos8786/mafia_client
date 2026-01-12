import 'dart:math';
import 'package:flutter/material.dart';

import '../models/game_enums.dart'; // Import Enums
import '../theme/app_colors.dart';

class ParticleBackground extends StatefulWidget {
  final GamePhase phase;

  const ParticleBackground({super.key, required this.phase});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  GamePhase _currentPhase = GamePhase.day;

  @override
  void initState() {
    super.initState();
    _currentPhase = widget.phase;
    _initParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant ParticleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.phase != oldWidget.phase) {
      setState(() {
        _currentPhase = widget.phase;
        _initParticles();
      });
    }
  }

  void _initParticles() {
    _particles.clear();
    int count = _currentPhase == GamePhase.day
        ? 20
        : 50; // More stars at night or waiting
    for (int i = 0; i < count; i++) {
      _particles.add(Particle(_random, _currentPhase));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var particle in _particles) {
          particle.update();
        }
        // RepaintBoundary improves performance by isolating the painting
        return RepaintBoundary(
          child: CustomPaint(
            painter: ParticlePainter(_particles, _currentPhase),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double speed;
  late double theta;
  late double radius;
  late double opacity;

  Particle(Random random, GamePhase phase) {
    reset(random, phase, firstSpawn: true);
  }

  void reset(Random random, GamePhase phase, {bool firstSpawn = false}) {
    x = random.nextDouble();
    y = firstSpawn
        ? random.nextDouble()
        : 1.1; // Start from bottom if respawning
    if (phase == GamePhase.night) {
      // Stars: Static or very slow twinkling
      speed = random.nextDouble() * 0.0005;
      y = random.nextDouble(); // Random Y for stars
    } else {
      // Day/Other: Floating dust/pollen, moving up
      speed = random.nextDouble() * 0.002 + 0.001;
    }

    theta = random.nextDouble() * 2 * pi;
    radius = random.nextDouble() * 2 + 1;
    opacity = random.nextDouble() * 0.5 + 0.1;
  }

  void update() {
    // Night stars barely move, just twinkle
    // Day particles float up
    y -= speed;
    if (y < -0.1) {
      y = 1.1;
      x = Random().nextDouble();
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final GamePhase phase;

  ParticlePainter(this.particles, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = phase == GamePhase.day
            ? Colors.white.withOpacity(particle.opacity)
            : AppColors.accentYellow.withOpacity(
                particle.opacity,
              ); // Star color

      double cx = particle.x * size.width;
      double cy = particle.y * size.height;

      // Draw Twinkle for night
      if (phase == GamePhase.night) {
        // Simple twinkle effect
        double twinkle = sin(
          DateTime.now().millisecondsSinceEpoch * 0.005 + particle.x * 10,
        );
        paint.color = paint.color.withOpacity(
          (0.3 + 0.4 * (twinkle + 1) / 2).clamp(0.0, 1.0),
        );
      }

      canvas.drawCircle(Offset(cx, cy), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
