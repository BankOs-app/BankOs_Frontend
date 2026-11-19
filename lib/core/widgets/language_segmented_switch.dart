import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../constants/app_colors.dart';
import '../localization/app_locale_provider.dart';

/// Conmutador de idioma interactivo sin banderas y con animación fluida de pastilla deslizante
class LanguageSegmentedSwitch extends ConsumerWidget {
  const LanguageSegmentedSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(localeNotifierProvider);
    final isEs = currentLang == AppLanguage.es;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pillWidth = (constraints.maxWidth - 4) / 2;

          return Stack(
            children: [
              // Pastilla animada con desplazamiento suave
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOutCubic,
                left: isEs ? 0 : pillWidth,
                top: 0,
                bottom: 0,
                width: pillWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Botones táctiles transparentes sobre la pastilla
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (!isEs) {
                          ref
                              .read(localeNotifierProvider.notifier)
                              .setLanguage(AppLanguage.es);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: isEs ? Colors.white : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight:
                                isEs ? FontWeight.bold : FontWeight.w600,
                          ),
                          child: const Text('Español'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (isEs) {
                          ref
                              .read(localeNotifierProvider.notifier)
                              .setLanguage(AppLanguage.en);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: !isEs ? Colors.white : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight:
                                !isEs ? FontWeight.bold : FontWeight.w600,
                          ),
                          child: const Text('English'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
