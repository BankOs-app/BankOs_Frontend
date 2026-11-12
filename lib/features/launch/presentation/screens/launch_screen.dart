import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bankos_logo.dart';
import '../widgets/wave_background_painter.dart';

class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    // Auto navigation to onboarding after brief launch presentation
    _navigationTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _navigateToOnboarding() {
    _navigationTimer?.cancel();
    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToOnboarding,
        child: Stack(
          children: [
            // Ambient wave texture in the lower section
            Positioned.fill(
              child: CustomPaint(
                painter: const WaveBackgroundPainter(),
              ),
            ),

            // BankOs centered brand logo
            const Center(
              child: BankOsLogo(
                iconSize: 58,
                fontSize: 42,
              ),
            ),

            // Minimalist circular loading indicator at bottom center
            Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brandCyan,
                    ),
                    backgroundColor: AppColors.brandCyan.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
