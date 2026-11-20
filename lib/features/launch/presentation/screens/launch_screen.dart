import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
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
    // Navegación automática a Onboarding tras presentación de marca
    _navigationTimer = Timer(const Duration(milliseconds: 2200), () {
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
    final lang = ref.watch(localeNotifierProvider);
    return Scaffold(
      backgroundColor: AppColors.launchBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToOnboarding,
        child: Stack(
          children: [
            // Smooth, subtle flowing wave texture at lower section
            const Positioned.fill(
              child: CustomPaint(painter: WaveBackgroundPainter()),
            ),

            // BankOs centered brand logo (vertical layout matching mockup)
            Center(
              child: BankOsLogo(
                isVertical: true,
                iconSize: 76,
                fontSize: 40,
                subtitle: Tr.launchSubtitle(lang),
                textColor: Colors.white,
                subtitleColor: Color(0xFFE2E8F0),
                subtitleFontSize: 15,
              ),
            ),

            // Subtle 3-dot bottom indicator matching design mockup
            Positioned(
              left: 0,
              right: 0,
              bottom: 52,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
