import 'package:material_ui/material_ui.dart';
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
      title: 'Banca digital\nsegura',
      subtitle:
          'Tu dinero y tu información protegidos con tecnología de última generación.',
      illustration: SecurityIllustrationWidget(),
    ),
    _OnboardingPageData(
      title: 'Haz crecer\ntu dinero',
      subtitle:
          'Ahorra, invierte y alcanza tus metas con herramientas simples y transparentes.',
      illustration: GrowthIllustrationWidget(),
    ),
    _OnboardingPageData(
      title: 'Todo en un\nsolo lugar',
      subtitle:
          'Tarjetas, transferencias, pagos y más, desde una sola app.',
      illustration: CardsIllustrationWidget(),
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
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top action bar with clean "Omitir" button matching mockup
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text(
                    'Omitir',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
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
                        // Clean, minimalist illustration
                        page.illustration,
                        const SizedBox(height: 32),

                        // Title in primary dark navy
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Subtitle in soft muted slate
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
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

            // 3-Dot Page Indicator
            OnboardingPageIndicator(
              count: _pages.length,
              currentIndex: _currentPage,
            ),

            const SizedBox(height: 24),

            // Action Button: Clean rounded rectangle, no exaggerated shadows or borders
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onActionButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastPage
                        ? AppColors.buttonAccent
                        : AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    isLastPage ? 'Comenzar' : 'Siguiente',
                    style: const TextStyle(
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
