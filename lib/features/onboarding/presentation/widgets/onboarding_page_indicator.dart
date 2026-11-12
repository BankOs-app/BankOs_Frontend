import 'package:flutter/material.dart';

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
            width: isSelected ? 16.0 : 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4.0),
            ),
          );
        },
      ),
    );
  }
}
