import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../../core/widgets/bank_brand_logo.dart';
import '../../../operations/presentation/providers/operations_providers.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendRecoveryCode() async {
    final lang = ref.read(localeNotifierProvider);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Tr.requiredEmail(lang)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              Tr.recoverySent(lang),
              style: TextStyle(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              Tr.recoverySentSub(lang, email),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(Tr.backToLogin(lang)),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(operationsNotifierProvider);
    final lang = ref.watch(localeNotifierProvider);
    final currentBank = operationsState.currentBank;
    final slug = currentBank.slug;

    // Colores según el banco activo
    final Color buttonBgColor;
    final Color buttonTextColor;
    final BorderSide? buttonBorder;
    final Color brandAccent;

    if (slug.contains('lombia')) {
      buttonBgColor = const Color(0xFF0F172A);
      buttonTextColor = const Color(0xFFFDDA24);
      buttonBorder = BorderSide(
        color: const Color(0xFFFDDA24).withValues(alpha: 0.6),
        width: 1.2,
      );
      brandAccent = const Color(0xFFFDDA24);
    } else if (slug.contains('santander')) {
      buttonBgColor = const Color(0xFFEC0000);
      buttonTextColor = Colors.white;
      buttonBorder = null;
      brandAccent = const Color(0xFFEC0000);
    } else if (slug.contains('nu')) {
      buttonBgColor = const Color(0xFF820AD1);
      buttonTextColor = Colors.white;
      buttonBorder = null;
      brandAccent = const Color(0xFF820AD1);
    } else if (slug.contains('bogota')) {
      buttonBgColor = const Color(0xFF002D72);
      buttonTextColor = Colors.white;
      buttonBorder = null;
      brandAccent = const Color(0xFF004BB1);
    } else {
      buttonBgColor = currentBank.primaryColor;
      buttonTextColor = Colors.white;
      buttonBorder = null;
      brandAccent = currentBank.accentColor;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryNavy,
            size: 20,
          ),
          onPressed: () => context.go('/login'),
        ),
        title: Text(
          Tr.forgotTitle(lang),
          style: TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Cabecera Institucional Oficial del Banco
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              (brandAccent == Colors.black
                                      ? const Color(0xFFFDDA24)
                                      : brandAccent)
                                  .withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: BankBrandLogo(
                        bank: currentBank,
                        size: 48,
                        showName: false,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentBank.name,
                      style: const TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Lock Illustration con tono de marca
              _buildLockIllustration(brandAccent),

              const SizedBox(height: 28),

              // Header Text
              Text(
                Tr.forgotSub(lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Tr.recoveryInstructions(lang, currentBank.name),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),

              const SizedBox(height: 32),

              // Email Input Field
              AuthTextField(
                controller: _emailController,
                hintText: Tr.email(lang),
                keyboardType: TextInputType.emailAddress,
                isDark: false,
              ),

              const SizedBox(height: 24),

              // "Enviar código de recuperación" Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendRecoveryCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBgColor,
                    foregroundColor: buttonTextColor,
                    elevation: 0,
                    side: buttonBorder,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: buttonTextColor,
                          ),
                        )
                      : Text(
                          Tr.sendRecovery(lang),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                            color: buttonTextColor,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockIllustration(Color brandAccent) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: brandAccent.withValues(alpha: 0.08),
        shape: BoxShape.circle,
        border: Border.all(
          color: brandAccent.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.lock_reset_rounded,
          color: brandAccent == Colors.black
              ? const Color(0xFF0F172A)
              : brandAccent,
          size: 48,
        ),
      ),
    );
  }
}
