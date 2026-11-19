import 'package:material_ui/material_ui.dart';
import '../constants/app_colors.dart';

class BankOsLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color textColor;
  final bool isVertical;
  final bool showText;
  final String? subtitle;
  final Color? subtitleColor;
  final double? subtitleFontSize;

  const BankOsLogo({
    super.key,
    this.iconSize = 52.0,
    this.fontSize = 38.0,
    this.textColor = AppColors.textOnDark,
    this.isVertical = false,
    this.showText = true,
    this.subtitle,
    this.subtitleColor,
    this.subtitleFontSize = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = SizedBox(
      width: iconSize,
      height: iconSize,
      child: CustomPaint(
        painter: _BankOsLogoPainter(),
      ),
    );

    if (!showText || fontSize <= 0) {
      return iconWidget;
    }

    final titleWidget = Text(
      'BankOs',
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 16),
          titleWidget,
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subtitleColor ?? Colors.white.withValues(alpha: 0.85),
                fontSize: subtitleFontSize,
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        const SizedBox(width: 14),
        titleWidget,
      ],
    );
  }
}

class _BankOsLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Geometric origami play/chevron shape
    // Design colors: #6DA5FA (accent), #1E3A8A (brand), #031F48 (navy)
    final topGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF8BB9FC),
        Color(0xFF6DA5FA),
        Color(0xFF1E3A8A),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bottomGradient = const LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color(0xFF031F48),
        Color(0xFF1E3A8A),
        Color(0xFF6DA5FA),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Outer triangular ribbon
    final mainPaint = Paint()
      ..shader = topGradient
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(w * 0.15, h * 0.08);
    path.lineTo(w * 0.78, h * 0.42);
    path.quadraticBezierTo(w * 0.96, h * 0.50, w * 0.78, h * 0.58);
    path.lineTo(w * 0.15, h * 0.92);
    path.quadraticBezierTo(w * 0.04, h * 0.98, w * 0.04, h * 0.84);
    path.lineTo(w * 0.04, h * 0.16);
    path.quadraticBezierTo(w * 0.04, h * 0.02, w * 0.15, h * 0.08);
    path.close();

    // Inner cutout creating origami fold
    final cutout = Path();
    cutout.moveTo(w * 0.32, h * 0.35);
    cutout.lineTo(w * 0.60, h * 0.50);
    cutout.lineTo(w * 0.32, h * 0.65);
    cutout.close();

    final logoPath = Path.combine(PathOperation.difference, path, cutout);
    canvas.drawPath(logoPath, mainPaint);

    // Bottom fold facet
    final foldPaint = Paint()
      ..shader = bottomGradient
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final foldPath = Path();
    foldPath.moveTo(w * 0.04, h * 0.55);
    foldPath.lineTo(w * 0.78, h * 0.58);
    foldPath.lineTo(w * 0.15, h * 0.92);
    foldPath.quadraticBezierTo(w * 0.04, h * 0.98, w * 0.04, h * 0.84);
    foldPath.close();

    final foldCombined = Path.combine(PathOperation.intersect, logoPath, foldPath);
    canvas.drawPath(foldCombined, foldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
