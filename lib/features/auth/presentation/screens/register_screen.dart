import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bankos_logo.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _documentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final documentNumber = _documentController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;

    // 1. Validar campos requeridos
    if (fullName.isEmpty) {
      _showSnackBar('Por favor, ingresa tu nombre completo.');
      return;
    }

    if (documentNumber.isEmpty) {
      _showSnackBar('Por favor, ingresa tu número de documento.');
      return;
    }

    if (email.isEmpty) {
      _showSnackBar('Por favor, ingresa tu correo electrónico.');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar('Ingresa un correo electrónico válido.');
      return;
    }

    if (phone.isEmpty) {
      _showSnackBar('Por favor, ingresa tu número de teléfono.');
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Por favor, ingresa una contraseña.');
      return;
    }

    if (password.length < 6) {
      _showSnackBar('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    if (password != passwordConfirm) {
      _showSnackBar('Las contraseñas no coinciden. Por favor verifica.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ref.read(authNotifierProvider.notifier).register(
          fullName: fullName,
          documentNumber: documentNumber,
          email: email,
          phone: phone,
          password: password,
        );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 28),
                SizedBox(width: 10),
                Text(
                  '¡Registro Exitoso!',
                  style: TextStyle(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu cuenta en BankOS ha sido creada exitosamente con los siguientes datos:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 14),
                _buildSummaryRow('Nombre:', fullName),
                _buildSummaryRow('Documento:', documentNumber),
                _buildSummaryRow('Correo:', email),
                _buildSummaryRow('Teléfono:', phone),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Entrar a BankOS'),
              ),
            ],
          ),
        );
      } else {
        final error = ref.read(authNotifierProvider).errorMessage;
        _showSnackBar(error ?? 'Error al procesar el registro.');
      }
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryNavy,
            size: 20,
          ),
          onPressed: () => context.go('/login'),
        ),
        title: const Text(
          'Registro',
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BankOs Logo Centered
                const Center(
                  child: BankOsLogo(
                    iconSize: 42,
                    fontSize: 30,
                    textColor: AppColors.primaryNavy,
                  ),
                ),

                const SizedBox(height: 18),

                const Center(
                  child: Text(
                    'Crea tu cuenta',
                    style: TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Completa tus datos personales para unirte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 1. fullName
                _buildFieldLabel('Nombre completo:'),
                AuthTextField(
                  controller: _fullNameController,
                  hintText: 'Carlos Gómez',
                  keyboardType: TextInputType.name,
                ),

                const SizedBox(height: 14),

                // 2. documentNumber
                _buildFieldLabel('Número de documento:'),
                AuthTextField(
                  controller: _documentController,
                  hintText: 'Número de documento',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 14),

                // 3. email
                _buildFieldLabel('Correo electrónico:'),
                AuthTextField(
                  controller: _emailController,
                  hintText: 'correo@ejemplo.com',
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                // 4. phone
                _buildFieldLabel('Teléfono:'),
                AuthTextField(
                  controller: _phoneController,
                  hintText: '+57 300 123 4567',
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 14),

                // 5. password
                _buildFieldLabel('Contraseña:'),
                AuthTextField(
                  controller: _passwordController,
                  hintText: 'Contraseña (mínimo 6 caracteres)',
                  isPassword: true,
                ),

                const SizedBox(height: 14),

                // 6. passwordConfirmation
                _buildFieldLabel('Verificación de contraseña:'),
                AuthTextField(
                  controller: _passwordConfirmController,
                  hintText: 'Confirmar contraseña',
                  isPassword: true,
                ),

                const SizedBox(height: 28),

                // Botón Registrarse
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                // Link to Login
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Ya tienes una cuenta? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: AppColors.brandBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryNavy,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
