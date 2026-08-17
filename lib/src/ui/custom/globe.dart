import 'dart:math';
import 'package:flutter/material.dart';
import 'package:landpage/src/utils/colors.dart';

/// Drop-in replacement for your existing AnimatedGlobe.
/// Same constructor signature -> no changes needed at the call site:
///   AnimatedGlobe(globeSize: 200, orbitRadius: 60, duration: Duration(seconds: 10))
class AnimatedGlobe extends StatefulWidget {
  final double globeSize;
  final String imagePath;
  final Duration duration;

  /// Radius of the circular orbit path (horizontal radius of the ellipse).
  final double orbitRadius;

  const AnimatedGlobe({
    super.key,
    this.globeSize = 220,
    this.imagePath = 'images/globe.png',
    this.duration = const Duration(seconds: 10),
    this.orbitRadius = 90,
  });

  @override
  State<AnimatedGlobe> createState() => _AnimatedGlobeState();
}

class _AnimatedGlobeState extends State<AnimatedGlobe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boxSize = widget.orbitRadius * 2 + widget.globeSize;
    // Flatter squash -> reads as a horizontal orbit plane instead of an
    // upright vertical loop.
    final verticalRadius = widget.orbitRadius * 0.25;

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Faint static orbit path, purely decorative.
          CustomPaint(
            size: Size(boxSize, boxSize),
            painter: _OrbitPathPainter(
              radiusX: widget.orbitRadius,
              radiusY: verticalRadius,
            ),
          ),

          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * 2 * pi;

              final dx = widget.orbitRadius * cos(angle);
              final dy = verticalRadius * sin(angle);

              // depth: 1 = nearest the viewer (front, big & bright),
              // 0 = farthest (back, small & dim). Drives scale/opacity/glow
              // so the globe visibly advances and recedes each loop.
              final depth = (sin(angle) + 1) / 2; // 0..1
              final scale = 0.72 + depth * 0.35; // 0.72 .. 1.07
              final opacity = 0.55 + depth * 0.45; // 0.55 .. 1.0

              return Transform.translate(
                offset: Offset(dx, dy),
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.globeSize,
                      height: widget.globeSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ringAccent.withValues(
                              alpha: 0.05 + 0.35 * depth,
                            ),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Transform.rotate(
                          // Self-spin, independent of orbit position ->
                          // reads as a spinning planet rather than a flat
                          // image being dragged around a path.
                          // Whole-number multiplier -> ends a full loop back
                          // at its starting rotation, so repeat() is seamless.
                          angle: angle * 2,
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OrbitPathPainter extends CustomPainter {
  final double radiusX;
  final double radiusY;

  _OrbitPathPainter({required this.radiusX, required this.radiusY});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppColors.glassFill
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = Rect.fromCenter(
      center: center,
      width: radiusX * 2,
      height: radiusY * 2,
    );

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPathPainter oldDelegate) => false;
}
