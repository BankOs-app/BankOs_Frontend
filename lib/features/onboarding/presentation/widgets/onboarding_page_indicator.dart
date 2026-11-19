import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) {
          final isSelected = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: isSelected ? 18.0 : 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.brandBlue
                  : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(4.0),
            ),
          );
        },
      ),
    );
  }
}
