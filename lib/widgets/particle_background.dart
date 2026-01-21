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
    bool isDayStyle =
        _currentPhase == GamePhase.day ||
        _currentPhase == GamePhase.lastWord ||
        _currentPhase == GamePhase.judgement;

    int count = isDayStyle ? 20 : 50; // More stars at night or waiting
    for (int i = 0; i < count; i++) {
      _particles.add(Particle(_random, _currentPhase));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime? _lastTime;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final now = DateTime.now();
        final lastTime = _lastTime ?? now;
        double dt = now.difference(lastTime).inMicroseconds / 1000000.0;
        _lastTime = now;

        // Prevent huge jumps if frame rate drops or app pauses
        if (dt > 0.1) dt = 0.016;

        for (var particle in _particles) {
          particle.update(dt);
        }
        // Create timeOffset efficiently once per frame
        final double timeOffset = now.millisecondsSinceEpoch * 0.005;

        // RepaintBoundary improves performance by isolating the painting
        return RepaintBoundary(
          child: CustomPaint(
            painter: ParticlePainter(_particles, _currentPhase, timeOffset),
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

  // Optim: Store Random instance to prevent creating new one each update/spawn
  final Random random;

  Particle(this.random, GamePhase phase) {
    reset(phase, firstSpawn: true);
  }

  void reset(GamePhase phase, {bool firstSpawn = false}) {
    x = random.nextDouble();
    y = firstSpawn
        ? random.nextDouble()
        : 1.1; // Start from bottom if respawning
    if (phase == GamePhase.night) {
      // Stars: Static or very slow twinkling
      // Old: 0.0005 per frame -> New: ~0.03 per second (60fps equiv)
      speed = random.nextDouble() * 0.03;
      y = random.nextDouble(); // Random Y for stars
    } else {
      // Day/Other: Floating dust/pollen, moving up
      // Old: 0.001~0.003 per frame -> New: 0.06 ~ 0.18 per second
      speed = random.nextDouble() * 0.12 + 0.06;
    }

    theta = random.nextDouble() * 2 * pi;
    radius = random.nextDouble() * 2 + 1;
    opacity = random.nextDouble() * 0.5 + 0.1;
  }

  void update(double dt) {
    // Night stars barely move, just twinkle
    // Day particles float up
    y -= speed * dt;
    if (y < -0.1) {
      y = 1.1;
      // Optim: Use stored random
      x = random.nextDouble();
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final GamePhase phase;
  final double timeOffset;

  ParticlePainter(this.particles, this.phase, this.timeOffset);

  @override
  void paint(Canvas canvas, Size size) {
    bool isDayStyle =
        phase == GamePhase.day ||
        phase == GamePhase.lastWord ||
        phase == GamePhase.judgement;

    for (var particle in particles) {
      final paint = Paint()
        ..color = isDayStyle
            ? Colors.white.withValues(alpha: particle.opacity)
            : AppColors.accentYellow.withValues(
                alpha: particle.opacity,
              ); // Star color

      double cx = particle.x * size.width;
      double cy = particle.y * size.height;

      // Draw Twinkle for night
      if (!isDayStyle) {
        // Simple twinkle effect
        // Optim: Use passed timeOffset instead of DateTime.now()
        double twinkle = sin(timeOffset + particle.x * 10);
        paint.color = paint.color.withValues(
          alpha: (0.3 + 0.4 * (twinkle + 1) / 2).clamp(0.0, 1.0),
        );
      }

      canvas.drawCircle(Offset(cx, cy), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true; // Still needs to animate
}
