import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final bool isDark;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.isDark = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF131D31) : AppColors.softBackground;
    final borderColor = widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textColor = widget.isDark ? Colors.white : AppColors.textPrimary;
    final hintColor = widget.isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword && _obscureText,
        keyboardType: widget.keyboardType,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
        ),
        cursorColor: AppColors.brandBlue,
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: hintColor, size: 20)
              : null,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: hintColor,
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          border: InputBorder.none,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: hintColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
