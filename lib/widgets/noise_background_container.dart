import 'dart:math';
import 'package:flutter/material.dart';

class NoiseBackgroundContainer extends StatelessWidget {
  final Widget child;
  final double dotSize; // in logical pixels
  final int density; // higher -> fewer dots per area
  final double opacity;
  final Color color;
  final double height; // give a fixed height so painter has definite size
  final double borderRadius;

  const NoiseBackgroundContainer({
    super.key,
    required this.child,
    this.dotSize = 0.5,
    this.density = 100,
    this.opacity = 0.15,
    this.color = const Color(0xFFFFFFFF),
    required this.height,
    this.borderRadius = 11.0,
  });

  @override
  Widget build(BuildContext context) {
    // Use ClipRRect to respect borderRadius and prevent paint overflow.
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Color(0xff3E3E3E),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        // RepaintBoundary helps performance
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _NoisePainter(
              dotSize: dotSize,
              density: density,
              opacity: opacity,
              color: color,
            ),
            // Important: child gives the painter the size. We place the content on top.
            child: child,
          ),
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  final double dotSize;
  final int density;
  final double opacity;
  final Color color;
  final Random _random = Random();

  _NoisePainter({
    required this.dotSize,
    required this.density,
    required this.opacity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final paint = Paint()..color = color.withOpacity(opacity);

    // Decide total dots safely — clamp to avoid extreme counts
    final area = size.width * size.height;
    final computed = (area / density).round();
    final totalDots = computed.clamp(200, 3000); // keep count reasonable

    // Draw small rectangles (reliable on all devices)
    final half = dotSize / 2.0;
    for (int i = 0; i < totalDots; i++) {
      final dx = _random.nextDouble() * size.width;
      final dy = _random.nextDouble() * size.height;

      // Slight variation in alpha for natural look
      final alphaFactor = 0.6 + _random.nextDouble() * 0.8; // 0.6 - 1.4
      paint.color = color.withOpacity((opacity * alphaFactor).clamp(0.0, 1.0));

      // Draw a tiny rect for robust single-pixel-like noise
      final rect = Rect.fromLTWH(dx - half, dy - half, dotSize, dotSize);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) {
    // return false for static noise (better performance).
    // If you want the noise to change on rebuild, return true.
    return false;
  }
}
