import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/onboarding_illustrations.dart';
import '../widgets/onboarding_page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Toma el control\nde tus finanzas',
      subtitle:
          'Seguridad financiera para tener control total de tus transacciones y finanzas.',
      illustration: SecurityIllustrationWidget(),
    ),
    _OnboardingPageData(
      title: 'Transferencias\nal instante',
      subtitle:
          'Envía y recibe dinero en segundos a cualquier banco sin comisiones ocultas.',
      illustration: TransfersIllustrationWidget(),
    ),
    _OnboardingPageData(
      title: 'Haz crecer\ntus ahorros',
      subtitle:
          'Monitorea tus gastos y haz crecer tu dinero con herramientas inteligentes.',
      illustration: SavingsIllustrationWidget(),
    ),
    _OnboardingPageData(
      title: 'Tu banco digital\nsiempre contigo',
      subtitle:
          'Accede y gestiona tus productos financieros 24/7 con máxima seguridad.',
      illustration: DigitalBankIllustrationWidget(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onActionButtonPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top action bar with optional Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textOnDarkMuted,
                  ),
                  child: const Text(
                    'Saltar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

            // PageView containing illustration, title & subtitle
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration
                        page.illustration,
                        const SizedBox(height: 36),

                        // Title
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textOnDark,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Subtitle
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textOnDarkMuted,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 4-Dot Page Indicator
            OnboardingPageIndicator(
              count: _pages.length,
              currentIndex: _currentPage,
            ),

            const SizedBox(height: 28),

            // Bottom "Comenzar" Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onActionButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Comenzar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
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

class _OnboardingPageData {
  final String title;
  final String subtitle;
  final Widget illustration;

  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.illustration,
  });
}
