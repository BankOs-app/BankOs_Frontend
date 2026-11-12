import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Screen 1: Security & Protection illustration matching the mockup exactly
class SecurityIllustrationWidget extends StatelessWidget {
  const SecurityIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ambient soft cloud backdrop
          Container(
            width: 250,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          // Laptop base & screen
          Positioned(
            bottom: 20,
            child: Container(
              width: 230,
              height: 155,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Screen header bar
                  Container(
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFBAE6FD),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                  // Mock content wireframe lines
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 90, height: 8, decoration: BoxDecoration(color: const Color(0xFF93C5FD), borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 8),
                        Container(width: 65, height: 6, decoration: BoxDecoration(color: const Color(0xFFBAE6FD), borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Left Person Figure
          Positioned(
            left: 24,
            bottom: 15,
            child: _buildPersonFigure(),
          ),

          // Center Prominent 3D Shield with Padlock
          Positioned(
            child: _buildSecurityShield(),
          ),

          // Right Stacks of Coins
          Positioned(
            right: 28,
            bottom: 18,
            child: _buildCoinStacks(),
          ),

          // Top-right floating verified checkmark badge
          Positioned(
            right: 50,
            top: 25,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF38BDF8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF38BDF8),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityShield() {
    return Container(
      width: 105,
      height: 125,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF60A5FA),
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(52),
          bottomRight: Radius.circular(52),
        ),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lock_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonFigure() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Head
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFFFED7AA),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 3),
        // Torso with blue shirt
        Container(
          width: 32,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF60A5FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description, size: 16, color: Colors.white),
        ),
        // Legs in dark navy pants
        Row(
          children: [
            Container(width: 8, height: 42, color: const Color(0xFF1E293B)),
            const SizedBox(width: 4),
            Container(width: 8, height: 42, color: const Color(0xFF1E293B)),
          ],
        ),
      ],
    );
  }

  Widget _buildCoinStacks() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Floating single coin
        _buildSingleCoin(28),
        const SizedBox(height: 4),
        // Stack of coins
        Container(
          width: 50,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFF60A5FA),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white70, width: 1.5),
          ),
          alignment: Alignment.center,
          child: const Text(
            '\$',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Container(
          width: 50,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleCoin(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF38BDF8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '\$',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Screen 2: Instant Transfers
class TransfersIllustrationWidget extends StatelessWidget {
  const TransfersIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Center(
        child: Container(
          width: 210,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.brandCyan.withValues(alpha: 0.3)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating / flow circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.brandCyan.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              // Credit card
              Container(
                width: 110,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen 3: Smart Savings & Growth
class SavingsIllustrationWidget extends StatelessWidget {
  const SavingsIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Center(
        child: Container(
          width: 210,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.brandCyan.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.brandCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.brandCyan,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '+12.5% anual',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Screen 4: 24/7 Digital Banking
class DigitalBankIllustrationWidget extends StatelessWidget {
  const DigitalBankIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Center(
        child: Container(
          width: 210,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.brandCyan.withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Icon(
              Icons.account_balance_rounded,
              color: AppColors.brandCyan,
              size: 72,
            ),
          ),
        ),
      ),
    );
  }
}
