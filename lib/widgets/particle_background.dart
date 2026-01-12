import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final Map<String, dynamic> mode; // { 'type': 'day' || 'night' }

  const ParticleBackground({super.key, required this.mode});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  String _currentType = 'day';

  @override
  void initState() {
    super.initState();
    _currentType = widget.mode['type'] ?? 'day';
    _initParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant ParticleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode['type'] != oldWidget.mode['type']) {
      setState(() {
        _currentType = widget.mode['type'];
        _initParticles();
      });
    }
  }

  void _initParticles() {
    _particles.clear();
    int count = _currentType == '낮' ? 20 : 50; // More stars at night
    for (int i = 0; i < count; i++) {
      _particles.add(Particle(_random, _currentType));
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
        return CustomPaint(
          painter: ParticlePainter(_particles, _currentType),
          size: Size.infinite,
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

  Particle(Random random, String type) {
    reset(random, type, firstSpawn: true);
  }

  void reset(Random random, String type, {bool firstSpawn = false}) {
    x = random.nextDouble();
    y = firstSpawn
        ? random.nextDouble()
        : 1.1; // Start from bottom if respawning
    if (type == '밤') {
      // Stars: Static or very slow twinkling
      speed = random.nextDouble() * 0.0005;
      y = random.nextDouble(); // Random Y for stars
    } else {
      // Day: Floating dust/pollen, moving up
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
  final String type;

  ParticlePainter(this.particles, this.type);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = type == '낮'
            ? Colors.white.withOpacity(particle.opacity)
            : Colors.yellowAccent.withOpacity(particle.opacity); // Star color

      double cx = particle.x * size.width;
      double cy = particle.y * size.height;

      // Draw Twinkle for night
      if (type == '밤') {
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
