import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword && _obscureText,
        keyboardType: widget.keyboardType,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        cursorColor: AppColors.brandBlue,
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: const Color(0xFF94A3B8), size: 20)
              : null,
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
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
                    color: const Color(0xFF94A3B8),
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
