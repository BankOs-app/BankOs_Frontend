import 'package:material_ui/material_ui.dart';
import '../constants/app_colors.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryNavy,
        primary: AppColors.primaryNavy,
        secondary: AppColors.brandBlue,
        tertiary: AppColors.accentBlue,
        surface: AppColors.surfaceBackground,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
    );
  }
}
