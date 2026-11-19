import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bankos_logo.dart';
import '../../domain/entities/user_entity.dart';
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
    final password = _passwordController.text;

    final isAdminEmail = email.toLowerCase().contains('admin');
    final role = isAdminEmail ? UserRole.admin : UserRole.client;

    final success = await ref.read(authNotifierProvider.notifier).login(
          email.isEmpty ? 'carlos@bankos.com' : email,
          password.isEmpty ? '••••••••' : password,
          role: role,
        );

    if (success && mounted) {
      final user = ref.read(authNotifierProvider).user;
      if (user?.isAdmin == true || isAdminEmail) {
        context.go('/admin');
      } else {
        context.go('/select-tenant');
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    final success =
        await ref.read(authNotifierProvider.notifier).loginWithBiometrics();

    if (success && mounted) {
      final user = ref.read(authNotifierProvider).user;
      if (user?.isAdmin == true) {
        context.go('/admin');
      } else {
        context.go('/select-tenant');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
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
                      const SizedBox(height: 40),

                      // BankOs Logo Centered
                      const Center(
                        child: BankOsLogo(
                          iconSize: 56,
                          fontSize: 40,
                          textColor: AppColors.primaryNavy,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ingresa a tu cuenta y gestiona tu dinero de forma segura.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Email Field
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'Correo electrónico',
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      AuthTextField(
                        controller: _passwordController,
                        hintText: 'Contraseña',
                        isPassword: true,
                      ),

                      const SizedBox(height: 24),

                      // Iniciar sesión Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ¿Olvidaste tu contraseña? Link
                      TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.brandBlue,
                        ),
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Biometrics Action Button
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : _handleBiometricLogin,
                        icon: const Icon(Icons.fingerprint_rounded, size: 24),
                        label: const Text(
                          'Ingresar con huella digital',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryNavy,
                          side: const BorderSide(
                              color: Color(0xFFE2E8F0), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),

                      const Spacer(),

                      // Bottom Register link
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '¿Aún no tienes cuenta? ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/register'),
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(
                                  color: AppColors.brandBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
