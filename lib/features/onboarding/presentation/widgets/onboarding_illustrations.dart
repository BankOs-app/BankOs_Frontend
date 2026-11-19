import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bankos_logo.dart';

/// Screen 1: Security & Protection illustration (Minimalist Phone + Shield)
class SecurityIllustrationWidget extends StatelessWidget {
  const SecurityIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft circular ambient backdrop
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: AppColors.softBackground,
                  shape: BoxShape.circle,
                ),
              ),

              // Smartphone wireframe
              Positioned(
                left: 36,
                top: 24,
                child: Container(
                  width: 112,
                  height: 168,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.brandBlue,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandBlue.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Speaker notch
                      Container(
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Spacer(),
                      // BankOs logo inside phone display
                      const SizedBox(
                        width: 44,
                        height: 44,
                        child: BankOsLogo(
                          iconSize: 44,
                          showText: false,
                        ),
                      ),
                      const Spacer(),
                      // Bottom home indicator bar
                      Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Sleek security shield in foreground
              Positioned(
                right: 28,
                bottom: 28,
                child: Container(
                  width: 62,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentBlue,
                        AppColors.brandBlue,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandBlue.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen 2: Financial Growth & Savings illustration (Bar Chart + Ascending Arrow + Gold Coins)
class GrowthIllustrationWidget extends StatelessWidget {
  const GrowthIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft circular ambient backdrop
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: AppColors.softBackground,
                  shape: BoxShape.circle,
                ),
              ),

              // Bar chart with 3 blue bars and ascending curve
              Positioned(
                bottom: 46,
                left: 36,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Bar 1
                    Container(
                      width: 24,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Bar 2
                    Container(
                      width: 24,
                      height: 74,
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Bar 3
                    Container(
                      width: 24,
                      height: 104,
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),

              // Soaring blue upward trend arrow
              Positioned(
                top: 36,
                left: 30,
                right: 38,
                child: CustomPaint(
                  size: const Size(150, 85),
                  painter: _TrendArrowPainter(),
                ),
              ),

              // Stack of golden coins at the bottom right
              Positioned(
                right: 28,
                bottom: 42,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCoin(),
                    const SizedBox(height: 3),
                    _buildCoin(),
                    const SizedBox(height: 3),
                    _buildCoin(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoin() {
    return Container(
      width: 32,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            blurRadius: 3,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
    );
  }
}

class _TrendArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, h * 0.95);
    path.cubicTo(w * 0.35, h * 0.85, w * 0.65, h * 0.25, w * 0.92, h * 0.08);

    final linePaint = Paint()
      ..color = AppColors.brandBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(path, linePaint);

    // Arrowhead at top right
    final arrowPaint = Paint()
      ..color = AppColors.brandBlue
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final arrowPath = Path();
    final tipX = w * 0.98;
    final tipY = h * 0.02;
    arrowPath.moveTo(tipX, tipY);
    arrowPath.lineTo(tipX - 16, tipY + 2);
    arrowPath.lineTo(tipX - 2, tipY + 16);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Screen 3: All in one place illustration (Two Overlapping Modern Cards with Contactless)
class CardsIllustrationWidget extends StatelessWidget {
  const CardsIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft circular ambient backdrop
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: AppColors.softBackground,
                  shape: BoxShape.circle,
                ),
              ),

              // Back card: Deep Navy Blue
              Positioned(
                top: 42,
                left: 36,
                child: Transform.rotate(
                  angle: -0.08,
                  child: Container(
                    width: 135,
                    height: 86,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryNavy.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: 18,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Front card: Deep Royal Blue with contactless wave icon
              Positioned(
                bottom: 46,
                right: 32,
                child: Container(
                  width: 145,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2563EB),
                        AppColors.brandBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandBlue.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Chip & Contactless wave symbol
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 22,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Icon(
                            Icons.contactless_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                      // Card number dots
                      Row(
                        children: List.generate(
                          3,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
