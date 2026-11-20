import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../../core/widgets/bank_brand_logo.dart';
import '../../../operations/presentation/providers/operations_providers.dart';
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
  static const int _totalSteps = 6;

  // Form Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();

  String _documentType = 'Cédula de Ciudadanía (CC)';
  bool _isLoading = false;

  String _tr(String spanish, String english) =>
      LocaleNotifier.currentLanguage == AppLanguage.es ? spanish : english;

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _documentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _pinController.dispose();
    _pinConfirmController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
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
          _showSnackBar(
            _tr(
              'Por favor, ingresa tu nombre completo.',
              'Enter your full name.',
            ),
          );
          return false;
        }
        if (name.length < 3) {
          _showSnackBar(
            _tr(
              'Ingresa un nombre válido (mínimo 3 caracteres).',
              'Enter a valid name (at least 3 characters).',
            ),
          );
          return false;
        }
        return true;

      case 1:
        final doc = _documentController.text.trim();
        if (doc.isEmpty) {
          _showSnackBar(
            _tr(
              'Por favor, ingresa tu número de documento.',
              'Enter your identification number.',
            ),
          );
          return false;
        }
        if (doc.length < 4) {
          _showSnackBar(
            _tr(
              'El número de documento debe tener al menos 4 dígitos.',
              'The identification number must contain at least 4 digits.',
            ),
          );
          return false;
        }
        return true;

      case 2:
        final email = _emailController.text.trim();
        if (email.isEmpty) {
          _showSnackBar(
            _tr(
              'Por favor, ingresa tu correo electrónico.',
              'Enter your email address.',
            ),
          );
          return false;
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(email)) {
          _showSnackBar(
            _tr(
              'Ingresa un correo electrónico válido (ej. usuario@correo.com).',
              'Enter a valid email address (e.g. user@example.com).',
            ),
          );
          return false;
        }
        return true;

      case 3:
        final phone = _phoneController.text.trim();
        if (phone.isEmpty) {
          _showSnackBar(
            _tr(
              'Por favor, ingresa tu número de teléfono.',
              'Enter your phone number.',
            ),
          );
          return false;
        }
        if (phone.length < 7) {
          _showSnackBar(
            _tr(
              'Ingresa un número de celular o teléfono válido.',
              'Enter a valid mobile or phone number.',
            ),
          );
          return false;
        }
        return true;

      case 4:
        final pass = _passwordController.text;
        final passConfirm = _passwordConfirmController.text;
        if (pass.isEmpty) {
          _showSnackBar(
            _tr(
              'Por favor, ingresa una contraseña de seguridad.',
              'Enter a secure password.',
            ),
          );
          return false;
        }
        if (pass.length < 6) {
          _showSnackBar(
            _tr(
              'La contraseña debe tener al menos 6 caracteres.',
              'The password must contain at least 6 characters.',
            ),
          );
          return false;
        }
        if (pass != passConfirm) {
          _showSnackBar(
            _tr(
              'Las contraseñas no coinciden. Por favor verifica.',
              'The passwords do not match. Please check them.',
            ),
          );
          return false;
        }
        return true;

      case 5:
        final pin = _pinController.text.trim();
        final pinConfirm = _pinConfirmController.text.trim();
        if (pin.isEmpty) {
          _showSnackBar(
            _tr(
              'Por favor, define tu PIN transaccional de 4 dígitos.',
              'Set your 4-digit transaction PIN.',
            ),
          );
          return false;
        }
        if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
          _showSnackBar(
            _tr(
              'El PIN de seguridad debe contener exactamente 4 dígitos numéricos.',
              'The security PIN must contain exactly 4 digits.',
            ),
          );
          return false;
        }
        if (pin != pinConfirm) {
          _showSnackBar(
            _tr(
              'Los PINes ingresados no coinciden. Por favor verifica.',
              'The PINs do not match. Please check them.',
            ),
          );
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
    final pin = _pinController.text.trim();

    setState(() {
      _isLoading = true;
    });

    final success = await ref
        .read(authNotifierProvider.notifier)
        .register(
          fullName: fullName,
          documentNumber: documentNumber,
          email: email,
          phone: phone,
          password: password,
          transactionalPin: pin,
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
            title: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  _tr('¡Registro exitoso!', 'Registration successful'),
                  style: const TextStyle(
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
                Text(
                  _tr(
                    'Tu cuenta bancaria en BankOS se creó correctamente. Ya puedes acceder a las entidades disponibles:',
                    'Your BankOS account was created successfully. You can now access the available institutions:',
                  ),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                _buildSummaryRow(_tr('Nombre:', 'Name:'), fullName),
                _buildSummaryRow(
                  _tr('Documento:', 'ID number:'),
                  '$documentNumber ($_documentType)',
                ),
                _buildSummaryRow(_tr('Correo:', 'Email:'), email),
                _buildSummaryRow(_tr('Teléfono:', 'Phone:'), phone),
                _buildSummaryRow(
                  _tr('PIN de operaciones:', 'Transaction PIN:'),
                  _tr('•••• (Configurado)', '•••• (Set)'),
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _tr('Entrar a BankOS', 'Continue to BankOS'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      } else {
        final error = ref.read(authNotifierProvider).errorMessage;
        _showSnackBar(
          error ??
              _tr(
                'No fue posible completar el registro. Revisa los datos e inténtalo de nuevo.',
                'Could not complete registration. Check your details and try again.',
              ),
        );
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
    ref.watch(localeNotifierProvider);
    final operationsState = ref.watch(operationsNotifierProvider);
    final currentBank = operationsState.currentBank;
    final slug = currentBank.slug;

    // Colores según la identidad del banco activo
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
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryNavy,
            size: 18,
          ),
          onPressed: _prevStep,
        ),
        title: Text(
          _tr('Registro de Cliente', 'Customer Registration'),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              _tr(
                'Paso ${_currentStep + 1} de $_totalSteps',
                'Step ${_currentStep + 1} of $_totalSteps',
              ),
              style: TextStyle(
                color: brandAccent == Colors.black
                    ? const Color(0xFFFDDA24)
                    : brandAccent,
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
            // Indicador de pasos exclusivo con números (sin barra duplicada, Foto 4)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_totalSteps, (index) {
                  final isDone = index < _currentStep;
                  final isCurrent = index == _currentStep;
                  final stepColor = isDone
                      ? const Color(0xFF10B981)
                      : isCurrent
                      ? buttonBgColor
                      : const Color(0xFFE2E8F0);
                  final textColor = isDone
                      ? Colors.white
                      : isCurrent
                      ? buttonTextColor
                      : const Color(0xFF94A3B8);

                  return Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: stepColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent
                                ? (brandAccent == Colors.black
                                      ? const Color(0xFFFDDA24)
                                      : brandAccent)
                                : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      if (index < _totalSteps - 1)
                        Container(
                          width:
                              (MediaQuery.of(context).size.width -
                                  48 -
                                  (30 * _totalSteps)) /
                              (_totalSteps - 1),
                          height: 2.5,
                          color: isDone
                              ? const Color(0xFF10B981)
                              : const Color(0xFFCBD5E1),
                        ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 6),

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
                  _buildStep6TransactionalPin(),
                ],
              ),
            ),

            // Controles inferiores: Atrás y Continuar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
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
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _tr('Atrás', 'Back'),
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
                            backgroundColor: buttonBgColor,
                            foregroundColor: buttonTextColor,
                            side: buttonBorder,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentStep == _totalSteps - 1
                                          ? _tr(
                                              'Crear mi cuenta',
                                              'Create my account',
                                            )
                                          : _tr('Continuar', 'Continue'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: buttonTextColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _currentStep == _totalSteps - 1
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: buttonTextColor,
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
                        Text(
                          _tr(
                            '¿Ya tienes una cuenta? ',
                            'Already have an account? ',
                          ),
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            _tr('Iniciar sesión', 'Sign in'),
                            style: TextStyle(
                              color: brandAccent == Colors.black
                                  ? const Color(0xFFFDDA24)
                                  : brandAccent,
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
    final currentBank = ref.watch(operationsNotifierProvider).currentBank;
    final slug = currentBank.slug;
    final brandAccent = slug.contains('lombia')
        ? const Color(0xFFFDDA24)
        : (slug.contains('santander')
              ? const Color(0xFFEC0000)
              : (slug.contains('nu')
                    ? const Color(0xFF820AD1)
                    : (slug.contains('bogota')
                          ? const Color(0xFF004BB1)
                          : currentBank.accentColor)));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        (brandAccent == Colors.black
                                ? const Color(0xFF0F172A)
                                : brandAccent)
                            .withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          (brandAccent == Colors.black
                                  ? const Color(0xFFFDDA24)
                                  : brandAccent)
                              .withValues(alpha: 0.3),
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
                  style: TextStyle(
                    color: slug.contains('lombia')
                        ? const Color(0xFF0F172A)
                        : brandAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildStepHeader(
            icon: Icons.person_rounded,
            title: _tr('¿Cómo te llamas?', 'What is your name?'),
            subtitle: _tr(
              'Ingresa tu nombre y apellidos tal como figuran en tu documento oficial de identidad.',
              'Enter your first and last name as shown on your official identification.',
            ),
          ),
          const SizedBox(height: 24),
          _buildFieldLabel(_tr('Nombre completo:', 'Full name:')),
          AuthTextField(
            controller: _fullNameController,
            hintText: _tr('Carlos Gómez', 'Alex Morgan'),
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_outline_rounded,
            isDark: false,
          ),
          const SizedBox(height: 20),
          _buildFeatureNotice(
            icon: Icons.verified_user_outlined,
            title: _tr('Verificación bancaria', 'Bank verification'),
            description: _tr(
              'Tu nombre completo se asociará a tus cuentas bancarias y certificados de titularidad.',
              'Your full name will be linked to your bank accounts and account ownership records.',
            ),
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
            title: _tr(
              '¿Cuál es tu identificación?',
              'What is your identification?',
            ),
            subtitle: _tr(
              'Selecciona tu tipo de documento e ingresa el número de identificación para el registro KYC.',
              'Select an identification type and enter its number for identity verification.',
            ),
          ),
          const SizedBox(height: 24),
          _buildFieldLabel(_tr('Tipo de documento:', 'Identification type:')),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF131D31),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _documentType,
                isExpanded: true,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primaryNavy,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Cédula de Ciudadanía (CC)',
                    child: Text(
                      _tr('Cédula de Ciudadanía (CC)', 'National ID (CC)'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Cédula de Extranjería (CE)',
                    child: Text(
                      _tr('Cédula de Extranjería (CE)', 'Foreigner ID (CE)'),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Pasaporte (PAS)',
                    child: Text(_tr('Pasaporte (PAS)', 'Passport (PAS)')),
                  ),
                  DropdownMenuItem(
                    value: 'NIT / Empresa',
                    child: Text(_tr('NIT Empresarial', 'Business tax ID')),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _documentType = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          _buildFieldLabel(
            _tr('Número de documento:', 'Identification number:'),
          ),
          AuthTextField(
            controller: _documentController,
            hintText: _tr('Número de documento', 'Identification number'),
            keyboardType: TextInputType.number,
            prefixIcon: Icons.numbers_rounded,
            isDark: false,
          ),
          const SizedBox(height: 20),
          _buildFeatureNotice(
            icon: Icons.security_rounded,
            title: _tr('Protección de datos', 'Data protection'),
            description: _tr(
              'Tus datos de identidad están protegidos con cifrado bancario.',
              'Your identity data is protected with banking-grade encryption.',
            ),
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
            title: _tr(
              '¿Cuál es tu correo electrónico?',
              'What is your email address?',
            ),
            subtitle: _tr(
              'Aquí recibirás comprobantes de transferencias, notificaciones y extractos bancarios.',
              'We will send transfer receipts, notifications, and bank statements to this address.',
            ),
          ),
          const SizedBox(height: 24),
          _buildFieldLabel(_tr('Correo electrónico:', 'Email address:')),
          AuthTextField(
            controller: _emailController,
            hintText: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
            isDark: false,
          ),
          const SizedBox(height: 20),
          _buildFeatureNotice(
            icon: Icons.mark_email_read_outlined,
            title: _tr('Canal oficial', 'Official channel'),
            description: _tr(
              'No compartiremos tu correo con terceros ni te pediremos tus claves por este medio.',
              'We will not share your email or ask for your passwords through this channel.',
            ),
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
            title: _tr(
              '¿Cuál es tu número celular?',
              'What is your mobile number?',
            ),
            subtitle: _tr(
              'Lo usaremos para alertas de transacciones y verificación en dos pasos (2FA).',
              'We will use it for transaction alerts and two-factor authentication (2FA).',
            ),
          ),
          const SizedBox(height: 24),
          _buildFieldLabel(_tr('Teléfono:', 'Phone:')),
          AuthTextField(
            controller: _phoneController,
            hintText: '+57 300 123 4567',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            isDark: false,
          ),
          const SizedBox(height: 20),
          _buildFeatureNotice(
            icon: Icons.sms_outlined,
            title: _tr('Alertas por SMS', 'SMS alerts'),
            description: _tr(
              'Recibe alertas en tu celular cuando haya movimientos en tu cuenta.',
              'Receive alerts on your phone when activity occurs in your account.',
            ),
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
            title: _tr(
              'Crea tu clave de acceso',
              'Create your sign-in password',
            ),
            subtitle: _tr(
              'Define una contraseña segura para iniciar sesión en tu cuenta bancaria.',
              'Choose a secure password to sign in to your bank account.',
            ),
          ),
          const SizedBox(height: 24),
          _buildFieldLabel(_tr('Contraseña:', 'Password:')),
          AuthTextField(
            controller: _passwordController,
            hintText: _tr(
              'Contraseña (mínimo 6 caracteres)',
              'Password (at least 6 characters)',
            ),
            isPassword: true,
            prefixIcon: Icons.lock_rounded,
            isDark: false,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(
            _tr('Verificación de contraseña:', 'Confirm password:'),
          ),
          AuthTextField(
            controller: _passwordConfirmController,
            hintText: _tr('Confirmar contraseña', 'Confirm password'),
            isPassword: true,
            prefixIcon: Icons.lock_reset_rounded,
            isDark: false,
          ),
          const SizedBox(height: 20),
          _buildFeatureNotice(
            icon: Icons.gpp_good_outlined,
            title: _tr(
              'Recomendaciones de seguridad',
              'Security recommendations',
            ),
            description: _tr(
              'Usa una contraseña exclusiva y evita incluir fechas de cumpleaños.',
              'Use a unique password and avoid including birthdays.',
            ),
          ),
        ],
      ),
    );
  }

  // PASO 6: PIN Transaccional de 4 Dígitos
  Widget _buildStep6TransactionalPin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            icon: Icons.shield_rounded,
            title: _tr('Crea tu PIN de seguridad', 'Create your security PIN'),
            subtitle: _tr(
              'Define un PIN numérico de 4 dígitos para autorizar operaciones bancarias.',
              'Set a 4-digit numeric PIN to authorize banking transactions.',
            ),
          ),
          const SizedBox(height: 24),
          _buildFieldLabel(
            _tr(
              'PIN transaccional (4 dígitos):',
              'Transaction PIN (4 digits):',
            ),
          ),
          AuthTextField(
            controller: _pinController,
            hintText: _tr(
              '4 dígitos numéricos (ej. 1234)',
              '4 digits (e.g. 1234)',
            ),
            isPassword: true,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.pin_outlined,
            isDark: false,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(_tr('Confirma tu PIN:', 'Confirm your PIN:')),
          AuthTextField(
            controller: _pinConfirmController,
            hintText: _tr(
              'Repite tu PIN de 4 dígitos',
              'Enter your 4-digit PIN again',
            ),
            isPassword: true,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.lock_reset_rounded,
            isDark: false,
          ),
          const SizedBox(height: 20),
          _buildFeatureNotice(
            icon: Icons.verified_user_rounded,
            title: _tr(
              'Firma digital de operaciones',
              'Transaction authorization',
            ),
            description: _tr(
              'Este PIN autoriza movimientos de dinero y es independiente de tu contraseña de acceso.',
              'This PIN authorizes money transfers and is separate from your sign-in password.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader({
    IconData? icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            color: Color(0xFF94A3B8),
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
        color: AppColors.softBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF94A3B8), size: 20),
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
                    color: Color(0xFF94A3B8),
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
