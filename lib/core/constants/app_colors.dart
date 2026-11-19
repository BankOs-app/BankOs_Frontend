import 'package:material_ui/material_ui.dart';

abstract class AppColors {
  // Official BankOs Palette (from Design System)
  static const Color primaryNavy = Color(0xFF031F48);      // #031F48 - Dark Navy (Primary)
  static const Color brandBlue = Color(0xFF1E3A8A);        // #1E3A8A - Deep Blue (Secondary)
  static const Color accentBlue = Color(0xFF6DA5FA);       // #6DA5FA - Light/Sky Blue (Accent)
  static const Color softBackground = Color(0xFFF3F6FF);   // #F3F6FF - Soft Ice Blue Background

  // Backgrounds & Surfaces (Predominantly White Interface)
  static const Color scaffoldBackground = Colors.white;
  static const Color surfaceBackground = Colors.white;
  static const Color cardWhite = Colors.white;
  static const Color launchBackground = Color(0xFF031F48);
  static const Color onboardingBackground = Colors.white;
  static const Color darkBackground = Color(0xFF031F48);

  // Buttons & Accents (Clean, non-exaggerated)
  static const Color buttonNavy = Color(0xFF031F48);
  static const Color buttonBlue = Color(0xFF031F48);
  static const Color buttonAccent = Color(0xFF6DA5FA);
  static const Color brandCyan = Color(0xFF1E3A8A);
  static const Color brandLightCyan = Color(0xFFE0EDFF);

  // Text Colors (High contrast on white surfaces)
  static const Color textPrimary = Color(0xFF031F48);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnDark = Colors.white;
  static const Color textOnDarkMuted = Color(0xFFCBD5E1);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFF1F5F9);

  // Utility / Status Colors
  static const Color slateDark = Color(0xFF031F48);
  static const Color slateLight = Color(0xFF334155);
  static const Color emeraldSecondary = Color(0xFF059669);
  static const Color emeraldSuccess = Color(0xFF10B981);
  static const Color actionBlue = Color(0xFF1E3A8A);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color neutralGray = Color(0xFF6B7280);
}
