import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bank_brand_logo.dart';
import '../../../../core/widgets/bankos_logo.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../../operations/presentation/providers/operations_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu correo electrónico.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu contraseña.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final isAdminEmail = email.toLowerCase().contains('admin');
    final role = isAdminEmail ? UserRole.admin : UserRole.client;

    final success = await ref.read(authNotifierProvider.notifier).login(
          email,
          password,
          role: role,
        );

    if (success && mounted) {
      ref.read(operationsNotifierProvider.notifier).switchActiveBankByEmail(email);
      final user = ref.read(authNotifierProvider).user;
      if (user?.isAdmin == true || isAdminEmail) {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    } else if (mounted) {
      final errorMsg = ref.read(authNotifierProvider).errorMessage ??
          'Error al iniciar sesión. Revisa tus credenciales.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleBiometricLogin() async {
    final isApple = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;

    if (!AuthRemoteDataSourceImpl.isBiometricsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApple
                ? 'Face ID está desactivado. Inicia sesión con tus credenciales para activarlo.'
                : 'La huella dactilar está desactivada. Inicia sesión con tus credenciales para activarla.',
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success =
        await ref.read(authNotifierProvider.notifier).loginWithBiometrics();

    if (success && mounted) {
      final user = ref.read(authNotifierProvider).user;
      if (user?.email != null) {
        ref.read(operationsNotifierProvider.notifier).switchActiveBankByEmail(user!.email);
      }
      if (user?.isAdmin == true) {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final operationsState = ref.watch(operationsNotifierProvider);
    final currentBank = operationsState.currentBank;
    final isSuperAdmin = currentBank.isGlobal;
    final isLoading = authState.status == AuthStatus.loading;

    // Configuración estética y sobria según el banco activo (Bancolombia, Santander, Nu, Bogotá)
    final slug = currentBank.code.toLowerCase();
    final Color buttonBgColor;
    final Color buttonTextColor;
    final BorderSide? buttonBorder;
    final Color linkColor;

    if (isSuperAdmin) {
      buttonBgColor = const Color(0xFF0052FF);
      buttonTextColor = Colors.white;
      buttonBorder = null;
      linkColor = const Color(0xFF0052FF);
    } else if (slug.contains('lombia')) {
      buttonBgColor = const Color(0xFF0F172A);
      buttonTextColor = const Color(0xFFFDDA24);
      buttonBorder = BorderSide(
        color: const Color(0xFFFDDA24).withValues(alpha: 0.6),
        width: 1.2,
      );
      linkColor = const Color(0xFF0F172A);
    } else if (slug.contains('santander')) {
      buttonBgColor = const Color(0xFFEC0000);
      buttonTextColor = Colors.white;
      buttonBorder = null;
      linkColor = const Color(0xFFEC0000);
    } else if (slug.contains('nu')) {
      buttonBgColor = const Color(0xFF820AD1);
      buttonTextColor = Colors.white;
      buttonBorder = null;
      linkColor = const Color(0xFF820AD1);
    } else if (slug.contains('bogota')) {
      buttonBgColor = const Color(0xFF002D72);
      buttonTextColor = Colors.white;
      buttonBorder = null;
      linkColor = const Color(0xFF004BB1);
    } else {
      buttonBgColor = currentBank.primaryColor;
      buttonTextColor = Colors.white;
      buttonBorder = null;
      linkColor = currentBank.primaryColor;
    }

    final isApple = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Barra superior con botón volver a selección de bancos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: AppColors.primaryNavy, size: 20),
                            onPressed: () => context.go('/select-tenant'),
                          ),
                          TextButton.icon(
                            onPressed: () => context.go('/select-tenant'),
                            icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.primaryNavy),
                            label: const Text(
                              'Elegir otro banco',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Cabecera Principal Institucional: Logo y Marca Oficial del Banco Seleccionado
                      if (isSuperAdmin) ...[
                        const Center(
                          child: BankOsLogo(
                            iconSize: 52,
                            fontSize: 34,
                            textColor: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_rounded, color: Color(0xFF0052FF), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'BankOs Core Global • SuperAdmin',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (buttonBorder?.color ?? buttonBgColor).withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: BankBrandLogo(bank: currentBank, size: 52, showName: false),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                currentBank.name,
                                style: const TextStyle(
                                  color: AppColors.primaryNavy,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isSuperAdmin
                            ? 'Ingresa tus credenciales de Administrador General para operar de forma segura.'
                            : 'Ingresa a tu cuenta de ${currentBank.name} de forma segura.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Email Field
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'Correo electrónico',
                        keyboardType: TextInputType.emailAddress,
                        isDark: false,
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      AuthTextField(
                        controller: _passwordController,
                        hintText: 'Contraseña',
                        isPassword: true,
                        isDark: false,
                      ),

                      const SizedBox(height: 24),

                      // Iniciar sesión Action Button adaptado a la identidad del banco
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBgColor,
                            foregroundColor: buttonTextColor,
                            elevation: 0,
                            side: buttonBorder,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: buttonTextColor,
                                  ),
                                )
                              : Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                    color: buttonTextColor,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ¿Olvidaste tu contraseña? Link
                      TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        style: TextButton.styleFrom(
                          foregroundColor: linkColor,
                        ),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: linkColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Biometrics Action Button (Face ID en Apple / Huella en Android)
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : _handleBiometricLogin,
                        icon: Icon(
                          isApple ? Icons.face_rounded : Icons.fingerprint_rounded,
                          size: 24,
                          color: AppColors.primaryNavy,
                        ),
                        label: Text(
                          isApple
                              ? 'Ingresar con Face ID'
                              : 'Ingresar con huella dactilar',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryNavy,
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                              color: Color(0xFFCBD5E1), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),

                      const Spacer(),

                      // Bottom Register link (Oculto para SuperAdmin por seguridad)
                      if (!isSuperAdmin)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿Aún no tienes cuenta? ',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/register'),
                                child: Text(
                                  'Registrarse',
                                  style: TextStyle(
                                    color: linkColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
