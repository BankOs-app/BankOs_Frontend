import 'package:flutter/material.dart';

class WaveBackgroundPainter extends CustomPainter {
  final Color waveColor;

  const WaveBackgroundPainter({
    this.waveColor = const Color(0xFF38BDF8),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Multiple layered flowing contour waves in the lower third of the screen
    final waveCount = 10;
    final startY = h * 0.60;
    final stepY = (h * 0.38) / waveCount;

    for (int i = 0; i < waveCount; i++) {
      final yOffset = startY + (i * stepY);
      final alpha = (0.06 + (i * 0.015)).clamp(0.04, 0.22);

      final paint = Paint()
        ..color = waveColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + (i * 0.08)
        ..isAntiAlias = true;

      final path = Path();
      path.moveTo(0, yOffset);

      // Create flowing curve with control points
      final cp1x = w * 0.25;
      final cp1y = yOffset - 35 + (i * 4);
      final cp2x = w * 0.70;
      final cp2y = yOffset + 45 - (i * 3);

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, w, yOffset - 15 + (i * 2));

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
