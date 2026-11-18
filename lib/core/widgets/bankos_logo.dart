import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BankOsLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color textColor;

  const BankOsLogo({
    super.key,
    this.iconSize = 52.0,
    this.fontSize = 38.0,
    this.textColor = AppColors.textOnDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CustomPaint(
            painter: _BankOsLogoPainter(),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'BankOs',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _BankOsLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gradient matching the cyan to royal blue logo in the mockup
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFBAE6FD), // soft cyan
        Color(0xFF38BDF8), // vibrant cyan
        Color(0xFF2563EB), // deep vibrant blue
      ],
      stops: [0.0, 0.45, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Stylized rounded "b" glyph contour
    final path = Path();
    final radius = w * 0.28;

    // Top left rounded corner
    path.moveTo(w * 0.32, 0);
    path.quadraticBezierTo(0, 0, 0, h * 0.35);

    // Left stem downwards to bottom
    path.lineTo(0, h * 0.65);
    path.quadraticBezierTo(0, h, w * 0.42, h);

    // Bottom right loop
    path.quadraticBezierTo(w, h, w, h * 0.58);
    path.quadraticBezierTo(w, h * 0.18, w * 0.55, h * 0.18);
    path.lineTo(w * 0.35, h * 0.18);
    path.quadraticBezierTo(w * 0.22, h * 0.18, w * 0.22, 0);
    path.close();

    // Inner cutout circle
    final holePath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(w * 0.52, h * 0.62),
          radius: radius * 0.60,
        ),
      );

    final finalPath = Path.combine(PathOperation.difference, path, holePath);
    canvas.drawPath(finalPath, paint);

    // Subtle inner highlight accent
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..isAntiAlias = true;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(w * 0.52, h * 0.62),
        radius: radius * 0.72,
      ),
      3.14,
      1.57,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
