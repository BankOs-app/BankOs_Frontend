import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';

class WaveBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  const WaveBackgroundPainter({
    this.primaryColor = AppColors.brandBlue,
    this.secondaryColor = AppColors.primaryNavy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Smooth, minimalist ambient wave curve in the lower section
    // Soft flowing wave matching the dark launch screen in the mockup
    final wavePath1 = Path();
    wavePath1.moveTo(0, h * 0.72);
    wavePath1.cubicTo(
      w * 0.35,
      h * 0.65,
      w * 0.65,
      h * 0.82,
      w,
      h * 0.70,
    );
    wavePath1.lineTo(w, h);
    wavePath1.lineTo(0, h);
    wavePath1.close();

    final wavePaint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.25),
          secondaryColor.withValues(alpha: 0.45),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.65, w, h * 0.35))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(wavePath1, wavePaint1);

    // Subtle second overlapping wave for organic depth
    final wavePath2 = Path();
    wavePath2.moveTo(0, h * 0.80);
    wavePath2.cubicTo(
      w * 0.40,
      h * 0.74,
      w * 0.70,
      h * 0.88,
      w,
      h * 0.78,
    );
    wavePath2.lineTo(w, h);
    wavePath2.lineTo(0, h);
    wavePath2.close();

    final wavePaint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor.withValues(alpha: 0.20),
          secondaryColor.withValues(alpha: 0.60),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.74, w, h * 0.26))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(wavePath2, wavePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
