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
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 5;

  // Form Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  String _documentType = 'Cédula de Ciudadanía (CC)';
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
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

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        final name = _fullNameController.text.trim();
        if (name.isEmpty) {
          _showSnackBar('Por favor, ingresa tu nombre completo.');
          return false;
        }
        if (name.length < 3) {
          _showSnackBar('Ingresa un nombre válido (mínimo 3 caracteres).');
          return false;
        }
        return true;

      case 1:
        final doc = _documentController.text.trim();
        if (doc.isEmpty) {
          _showSnackBar('Por favor, ingresa tu número de documento.');
          return false;
        }
        if (doc.length < 4) {
          _showSnackBar('El número de documento debe tener al menos 4 dígitos.');
          return false;
        }
        return true;

      case 2:
        final email = _emailController.text.trim();
        if (email.isEmpty) {
          _showSnackBar('Por favor, ingresa tu correo electrónico.');
          return false;
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(email)) {
          _showSnackBar('Ingresa un correo electrónico válido (ej. usuario@correo.com).');
          return false;
        }
        return true;

      case 3:
        final phone = _phoneController.text.trim();
        if (phone.isEmpty) {
          _showSnackBar('Por favor, ingresa tu número de teléfono.');
          return false;
        }
        if (phone.length < 7) {
          _showSnackBar('Ingresa un número de celular o teléfono válido.');
          return false;
        }
        return true;

      case 4:
        final pass = _passwordController.text;
        final passConfirm = _passwordConfirmController.text;
        if (pass.isEmpty) {
          _showSnackBar('Por favor, ingresa una contraseña de seguridad.');
          return false;
        }
        if (pass.length < 6) {
          _showSnackBar('La contraseña debe tener al menos 6 caracteres.');
          return false;
        }
        if (pass != passConfirm) {
          _showSnackBar('Las contraseñas no coinciden. Por favor verifica.');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _handleRegister();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final documentNumber = _documentController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

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
              borderRadius: BorderRadius.circular(22),
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
                  'Tu cuenta bancaria en BankOS ha sido creada exitosamente. Ya puedes acceder a todas las entidades del sistema:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 14),
                _buildSummaryRow('Nombre:', fullName),
                _buildSummaryRow('Documento:', '$documentNumber ($_documentType)'),
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
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Entrar a BankOS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
            width: 85,
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryNavy,
            size: 18,
          ),
          onPressed: _prevStep,
        ),
        title: const Text(
          'Registro de Cliente',
          style: TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 14, bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.softBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Paso ${_currentStep + 1} de $_totalSteps',
              style: const TextStyle(
                color: AppColors.brandBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de progreso animada
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      tween: Tween<double>(begin: 0, end: progress),
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandBlue),
                          minHeight: 6,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Indicador de pasos con iconos / números
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_totalSteps, (index) {
                      final isDone = index < _currentStep;
                      final isCurrent = index == _currentStep;
                      return Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? const Color(0xFF10B981)
                                  : isCurrent
                                      ? AppColors.primaryNavy
                                      : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCurrent
                                    ? AppColors.brandBlue
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: isCurrent
                                            ? Colors.white
                                            : const Color(0xFF94A3B8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          if (index < _totalSteps - 1)
                            Container(
                              width: (MediaQuery.of(context).size.width - 48 - (28 * _totalSteps)) / (_totalSteps - 1),
                              height: 2,
                              color: isDone
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFE2E8F0),
                            ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // PageView con transición suave entre pasos
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Name(),
                  _buildStep2Document(),
                  _buildStep3Email(),
                  _buildStep4Phone(),
                  _buildStep5Password(),
                ],
              ),
            ),

            // Controles inferiores: Atrás y Continuar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (_currentStep > 0) ...[
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _prevStep,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryNavy,
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Atrás',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentStep == _totalSteps - 1
                                          ? 'Crear mi cuenta'
                                          : 'Continuar',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _currentStep == _totalSteps - 1
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.arrow_forward_rounded,
                                      size: 18,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Enlace a Iniciar Sesión
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya tienes una cuenta? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Iniciar sesión',
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
          ],
        ),
      ),
    );
  }

  // PASO 1: Nombre Completo
  Widget _buildStep1Name() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: BankOsLogo(iconSize: 38, fontSize: 26, textColor: AppColors.primaryNavy),
          ),
          const SizedBox(height: 20),
          _buildStepHeader(
            icon: Icons.person_rounded,
            title: '¿Cómo te llamas?',
            subtitle: 'Ingresa tu nombre y apellidos tal como figuran en tu documento oficial de identidad.',
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('Nombre completo:'),
          AuthTextField(
            controller: _fullNameController,
            hintText: 'Carlos Gómez',
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 20),
          _buildFeatureNotice(
            icon: Icons.verified_user_outlined,
            title: 'Verificación Bancaria',
            description: 'Tu nombre completo será asociado a tus cuentas bancarias y certificados de titularidad.',
          ),
        ],
      ),
    );
  }

  // PASO 2: Documento de Identidad
  Widget _buildStep2Document() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Icons.badge_rounded,
            title: '¿Cuál es tu identificación?',
            subtitle: 'Selecciona tu tipo de documento e ingresa el número de identificación para el registro KYC.',
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('Tipo de documento:'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _documentType,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryNavy),
                items: const [
                  DropdownMenuItem(value: 'Cédula de Ciudadanía (CC)', child: Text('Cédula de Ciudadanía (CC)')),
                  DropdownMenuItem(value: 'Cédula de Extranjería (CE)', child: Text('Cédula de Extranjería (CE)')),
                  DropdownMenuItem(value: 'Pasaporte (PAS)', child: Text('Pasaporte (PAS)')),
                  DropdownMenuItem(value: 'NIT / Empresa', child: Text('NIT Empresarial')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _documentType = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          _buildFieldLabel('Número de documento:'),
          AuthTextField(
            controller: _documentController,
            hintText: 'Número de documento',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.numbers_rounded,
          ),
          const SizedBox(height: 20),
          _buildFeatureNotice(
            icon: Icons.security_rounded,
            title: 'Protección de Datos KYC',
            description: 'Tus datos de identidad están protegidos por cifrado bancario de extremo a extremo.',
          ),
        ],
      ),
    );
  }

  // PASO 3: Correo Electrónico
  Widget _buildStep3Email() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Icons.alternate_email_rounded,
            title: '¿Cuál es tu correo electrónico?',
            subtitle: 'Aquí recibirás tus comprobantes de transferencias, notificaciones y extractos bancarios.',
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('Correo electrónico:'),
          AuthTextField(
            controller: _emailController,
            hintText: 'correo@ejemplo.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 20),
          _buildFeatureNotice(
            icon: Icons.mark_email_read_outlined,
            title: 'Canal Oficial',
            description: 'Nunca compartiremos tu correo con terceros ni te pediremos claves por este medio.',
          ),
        ],
      ),
    );
  }

  // PASO 4: Teléfono Celular
  Widget _buildStep4Phone() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Icons.phone_iphone_rounded,
            title: '¿Cuál es tu número celular?',
            subtitle: 'Lo utilizaremos para alertas de transacciones inmediatas y verificación de dos factores (2FA).',
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('Teléfono:'),
          AuthTextField(
            controller: _phoneController,
            hintText: '+57 300 123 4567',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: 20),
          _buildFeatureNotice(
            icon: Icons.sms_outlined,
            title: 'Alertas SMS en Tiempo Real',
            description: 'Recibe alertas instantáneas en tu celular cada vez que haya un movimiento en tu cuenta.',
          ),
        ],
      ),
    );
  }

  // PASO 5: Contraseña y Confirmación
  Widget _buildStep5Password() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Icons.lock_outline_rounded,
            title: 'Crea tu clave de acceso',
            subtitle: 'Define una contraseña segura o PIN maestro para autorizar todas tus transferencias y retiros.',
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('Contraseña:'),
          AuthTextField(
            controller: _passwordController,
            hintText: 'Contraseña (mínimo 6 caracteres)',
            isPassword: true,
            prefixIcon: Icons.lock_rounded,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Verificación de contraseña:'),
          AuthTextField(
            controller: _passwordConfirmController,
            hintText: 'Confirmar contraseña',
            isPassword: true,
            prefixIcon: Icons.lock_reset_rounded,
          ),
          const SizedBox(height: 20),
          _buildFeatureNotice(
            icon: Icons.gpp_good_outlined,
            title: 'Recomendaciones de Seguridad',
            description: 'Usa una contraseña que no compartas con otros servicios y evita fechas de cumpleaños.',
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Icon(icon, color: AppColors.brandBlue, size: 24),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
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

  Widget _buildFeatureNotice({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
