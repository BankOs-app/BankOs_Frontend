import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../../core/widgets/interactive_toggle_card.dart';
import '../../../../core/widgets/language_segmented_switch.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/operations_providers.dart';

/// PANTALLA DE PERFIL (BankOs):
/// - Animaciones fluidas Container Transform (`OpenContainer`) en cada tarjeta del menú.
/// - Conmutador de idioma dinámico sin banderas con deslizamiento suave.
/// - Controles interactivos reales (ON / OFF) para biometría, token y notificaciones.
class ProfileScreen extends ConsumerStatefulWidget {
  final bool showBackButton;

  const ProfileScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Estados interactivos configurables por el usuario (ON / OFF)
  bool _pushNotifications = true;
  bool _emailAlertsEnabled = true;
  late bool _biometricsEnabled;
  bool _digitalTokenEnabled = true;
  bool _loginAlertsEnabled = true;
  bool _cardAutoLockEnabled = true;

  @override
  void initState() {
    super.initState();
    _biometricsEnabled = AuthRemoteDataSourceImpl.isBiometricsEnabled;
  }

  // =========================================================================
  // VISTAS MODALES / DE DETALLE PARA CONTAINER TRANSFORM
  // =========================================================================

  Widget _buildPersonalDataContent(
      BuildContext context, StateSetter setModalState, AppLanguage lang, VoidCallback onClose) {
    final isEs = lang == AppLanguage.es;
    final authUser = ref.read(authNotifierProvider).user;
    final displayName = (authUser?.name != null &&
            authUser!.name!.isNotEmpty &&
            authUser.name != 'BankOS User' &&
            authUser.name != 'Usuario BankOS')
        ? authUser.name!
        : (authUser?.email != null && authUser!.email.isNotEmpty
            ? authUser.email.split('@')[0]
            : 'Alejandro Morales');
    final displayEmail = authUser?.email ?? 'cliente@bancolombia.com';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.badge_outlined,
                      color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  isEs ? 'Datos personales' : 'Personal Data',
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          icon: Icons.person_outline_rounded,
          label: isEs ? 'Nombre completo' : 'Full Name',
          value: displayName,
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          icon: Icons.mail_outline_rounded,
          label: isEs ? 'Correo electrónico' : 'Email Address',
          value: displayEmail,
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          icon: Icons.fingerprint_rounded,
          label: isEs ? 'Identificación / C.C.' : 'Document ID',
          value: '1098765432 - Colombia',
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          icon: Icons.verified_user_rounded,
          label: isEs ? 'Estado de la cuenta' : 'Account Status',
          value: isEs ? 'Titular Activo y Verificado' : 'Active & Verified Holder',
          badgeText: isEs ? 'Verificado' : 'Verified',
          badgeColor: const Color(0xFF10B981),
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          icon: Icons.credit_card_rounded,
          label: isEs
              ? 'Cuentas activas del titular'
              : 'Active Titular Accounts',
          value: isEs
              ? '3 cuentas multimoneda'
              : '3 multi-currency accounts',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              isEs ? 'Entendido' : 'Got it',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityContent(
      BuildContext context, StateSetter setModalState, AppLanguage lang, VoidCallback onClose) {
    final isEs = lang == AppLanguage.es;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_outlined,
                      color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  isEs ? 'Seguridad y Privacidad' : 'Security & Privacy',
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 1. Control interactivo de Autenticación Biométrica (Face ID en Apple / Huella Dactilar en Android)
        Builder(builder: (context) {
          final isApple = Theme.of(context).platform == TargetPlatform.iOS ||
              Theme.of(context).platform == TargetPlatform.macOS;
          final bioTitle = isApple
              ? 'Face ID'
              : (isEs ? 'Huella dactilar' : 'Fingerprint Auth');
          final bioSubtitle = _biometricsEnabled
              ? (isApple
                  ? (isEs ? 'Reconocimiento facial activo' : 'Face ID recognition active')
                  : (isEs ? 'Sensor de huella dactilar activo' : 'Fingerprint sensor active'))
              : (isApple
                  ? (isEs ? 'Reconocimiento facial desactivado' : 'Face ID disabled')
                  : (isEs ? 'Sensor de huella dactilar desactivado' : 'Fingerprint sensor disabled'));
          final bioIcon = isApple ? Icons.face_rounded : Icons.fingerprint_rounded;

          return InteractiveToggleCard(
            icon: bioIcon,
            title: bioTitle,
            subtitle: bioSubtitle,
            value: _biometricsEnabled,
            activeBadgeText: 'ON',
            inactiveBadgeText: 'OFF',
            onChanged: (val) {
              AuthRemoteDataSourceImpl.isBiometricsEnabled = val;
              setModalState(() => _biometricsEnabled = val);
              setState(() => _biometricsEnabled = val);
            },
          );
        }),

        const SizedBox(height: 10),

        // 2. Control interactivo de Token Digital BankOs (ON / OFF)
        InteractiveToggleCard(
          icon: Icons.vpn_key_rounded,
          title: isEs ? 'Token digital de seguridad' : 'Digital Security Token',
          subtitle: _digitalTokenEnabled
              ? (isEs
                  ? 'Sincronizado vía OTP dinámico'
                  : 'Synced via Dynamic OTP')
              : (isEs
                  ? 'Generación de OTP pausada'
                  : 'Dynamic OTP generation paused'),
          value: _digitalTokenEnabled,
          activeBadgeText: 'ON',
          inactiveBadgeText: 'OFF',
          activeBadgeColor: const Color(0xFF0284C7),
          onChanged: (val) {
            setModalState(() => _digitalTokenEnabled = val);
            setState(() => _digitalTokenEnabled = val);
          },
        ),

        const SizedBox(height: 10),

        // 3. Control interactivo de Alertas de Inicio de Sesión (ON / OFF)
        InteractiveToggleCard(
          icon: Icons.shield_rounded,
          title: isEs ? 'Alertas de inicio de sesión' : 'Login Alerts',
          subtitle: _loginAlertsEnabled
              ? (isEs ? 'Notificación inmediata activa' : 'Instant alerts active')
              : (isEs ? 'Alertas de acceso pausadas' : 'Access alerts paused'),
          value: _loginAlertsEnabled,
          activeBadgeText: 'ON',
          inactiveBadgeText: 'OFF',
          onChanged: (val) {
            setModalState(() => _loginAlertsEnabled = val);
            setState(() => _loginAlertsEnabled = val);
          },
        ),

        const SizedBox(height: 10),

        // 4. Control interactivo de Bloqueo de Tarjeta por Inactividad (ON / OFF)
        InteractiveToggleCard(
          icon: Icons.credit_card_off_rounded,
          title: isEs ? 'Bloqueo por inactividad' : 'Inactivity Card Lock',
          subtitle: _cardAutoLockEnabled
              ? (isEs ? 'Protección tras 5 min' : 'Protected after 5 min')
              : (isEs ? 'Protección desactivada' : 'Protection disabled'),
          value: _cardAutoLockEnabled,
          activeBadgeText: 'ON',
          inactiveBadgeText: 'OFF',
          activeBadgeColor: const Color(0xFF0284C7),
          onChanged: (val) {
            setModalState(() => _cardAutoLockEnabled = val);
            setState(() => _cardAutoLockEnabled = val);
          },
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              isEs ? 'Aceptar' : 'Accept',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigContent(
      BuildContext context, StateSetter setModalState, AppLanguage lang, VoidCallback onClose) {
    final isEs = lang == AppLanguage.es;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  isEs ? 'Configuración' : 'Settings',
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // SECCIÓN IDIOMA INTERACTIVO (Sin Banderas, Animación Suave)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.softBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.language_rounded,
                      color: AppColors.primaryNavy, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isEs
                        ? 'Idioma de la Aplicación'
                        : 'Application Language',
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isEs
                    ? 'Cambia el idioma para todos los perfiles (Admin y Clientes).'
                    : 'Change language for all profiles (Admin & Clients).',
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 11),
              ),
              const SizedBox(height: 12),
              const LanguageSegmentedSwitch(),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Notificaciones push en tiempo real (Switch ON / OFF interactivo)
        InteractiveToggleCard(
          icon: Icons.notifications_active_outlined,
          title: isEs
              ? 'Notificaciones push en tiempo real'
              : 'Real-time Push Notifications',
          subtitle: _pushNotifications
              ? (isEs
                  ? 'Alertas de depósitos y transacciones activas'
                  : 'Active transaction & deposit alerts')
              : (isEs
                  ? 'Alertas en tiempo real pausadas'
                  : 'Real-time push alerts paused'),
          value: _pushNotifications,
          activeBadgeText: 'ON',
          inactiveBadgeText: 'OFF',
          onChanged: (val) {
            setModalState(() => _pushNotifications = val);
            setState(() => _pushNotifications = val);
          },
        ),

        const SizedBox(height: 10),

        InteractiveToggleCard(
          icon: Icons.mail_outline_rounded,
          title: isEs ? 'Alertas por correo' : 'Email Alerts',
          subtitle: _emailAlertsEnabled
              ? (isEs ? 'Comprobantes de transacción activos' : 'Transaction receipts active')
              : (isEs ? 'Alertas por correo pausadas' : 'Email alerts paused'),
          value: _emailAlertsEnabled,
          activeBadgeText: 'ON',
          inactiveBadgeText: 'OFF',
          onChanged: (val) {
            setModalState(() => _emailAlertsEnabled = val);
            setState(() => _emailAlertsEnabled = val);
          },
        ),

        const SizedBox(height: 10),

        // Biometría: Face ID (Apple) / Huella Dactilar (Android) con switch interactivo ON / OFF
        InteractiveToggleCard(
          icon: Icons.fingerprint_rounded,
          title: isEs ? 'Face ID / Huella Dactilar' : 'Face ID / Fingerprint Auth',
          subtitle: _biometricsEnabled
              ? (isEs
                  ? 'Autenticación biométrica activa para acceso rápido'
                  : 'Biometric authentication active for fast access')
              : (isEs
                  ? 'Autenticación biométrica desactivada'
                  : 'Biometric authentication disabled'),
          value: _biometricsEnabled,
          activeBadgeText: 'ON',
          inactiveBadgeText: 'OFF',
          onChanged: (val) {
            setModalState(() => _biometricsEnabled = val);
            setState(() => _biometricsEnabled = val);
          },
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              isEs ? 'Guardar Cambios' : 'Save Changes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpContent(
      BuildContext context, StateSetter setModalState, AppLanguage lang, VoidCallback onClose) {
    final isEs = lang == AppLanguage.es;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.help_outline_rounded,
                      color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  isEs ? 'Ayuda y Soporte' : 'Help & Support',
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          icon: Icons.support_agent_rounded,
          label: isEs
              ? 'Centro de soporte BankOs'
              : 'BankOs Support Center',
          value: 'soporte@bankos.io • 24/7 Activo',
          badgeText: isEs ? 'En línea' : 'Online',
          badgeColor: const Color(0xFF059669),
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          icon: Icons.question_answer_outlined,
          label: isEs
              ? 'Preguntas frecuentes (FAQ)'
              : 'Frequently Asked Questions',
          value: isEs
              ? 'Límites operativos y cuentas de ahorro'
              : 'Operating limits & savings accounts',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              isEs ? 'Cerrar' : 'Close',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, AppLanguage lang) {
    final isEs = lang == AppLanguage.es;
    final currentBank = ref.read(operationsNotifierProvider).currentBank;
    final bankName = currentBank.isGlobal ? 'BankOS Core Global' : currentBank.name;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: Color(0xFFEF4444), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEs ? 'Cerrar sesión' : 'Sign Out',
                      style: const TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isEs
                      ? '¿Estás seguro de que deseas salir de tu cuenta de $bankName? Deberás ingresar tus credenciales nuevamente.'
                      : 'Are you sure you want to sign out from your $bankName account? You will need to log in again.',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text(
                          isEs ? 'Cancelar' : 'Cancel',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/select-tenant');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text(
                          isEs ? 'Sí, Salir' : 'Yes, Sign Out',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Subwidget informativo con icono y badge
  static Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    String? badgeText,
    Color badgeColor = const Color(0xFF0284C7),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.softBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, color: AppColors.primaryNavy, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (badgeText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // BUILD PRINCIPAL (RESPONSIVE IPAD & MÓVIL)
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeNotifierProvider);
    final isEs = lang == AppLanguage.es;
    final authUser = ref.watch(authNotifierProvider).user;
    final displayName = (authUser?.name != null &&
            authUser!.name!.isNotEmpty &&
            authUser.name != 'BankOS User' &&
            authUser.name != 'Usuario BankOS')
        ? authUser.name!
        : (authUser?.email != null && authUser!.email.isNotEmpty
            ? authUser.email.split('@')[0]
            : 'Alejandro Morales');
    final displayEmail = authUser?.email ?? 'cliente@bancolombia.com';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.showBackButton
          ? AppBar(
              backgroundColor: const Color(0xFFF8FAFC),
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.primaryNavy,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                isEs ? 'Mi perfil' : 'My Profile',
                style: const TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  if (!widget.showBackButton) ...[
                    const SizedBox(height: 8),
                    Text(
                      isEs ? 'Mi perfil' : 'My Profile',
                      style: const TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                const SizedBox(height: 12),

                // Avatar & Profile Picture
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.softBackground,
                          border:
                              Border.all(color: const Color(0xFFE2E8F0), width: 2),
                        ),
                        child: const ClipOval(
                          child: Icon(
                            Icons.person_rounded,
                            size: 56,
                            color: AppColors.brandBlue,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryNavy,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // User Name & Email
                Text(
                  displayName,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayEmail,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 10),

                // Verified Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF059669), size: 14),
                      const SizedBox(width: 5),
                      Text(
                        isEs ? 'Cuenta verificada' : 'Verified Account',
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Lista de Opciones con animación CONTAINER TRANSFORM (`OpenContainer`)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      children: [
                        // 1. Datos personales (Container Transform)
                        _buildContainerTransformTile(
                          icon: Icons.person_outline_rounded,
                          title: Tr.personalData(lang),
                          contentBuilder: (ctx, setModalState, close) =>
                              _buildPersonalDataContent(ctx, setModalState, lang, close),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),

                        // 2. Seguridad (Container Transform)
                        _buildContainerTransformTile(
                          icon: Icons.shield_outlined,
                          title: Tr.security(lang),
                          contentBuilder: (ctx, setModalState, close) =>
                              _buildSecurityContent(ctx, setModalState, lang, close),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),

                        // 3. Configuración (Container Transform)
                        _buildContainerTransformTile(
                          icon: Icons.tune_rounded,
                          title: Tr.settings(lang),
                          trailingWidget: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isEs ? 'ES / EN' : 'EN / ES',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          contentBuilder: (ctx, setModalState, close) =>
                              _buildConfigContent(ctx, setModalState, lang, close),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),

                        // 4. Ayuda (Container Transform)
                        _buildContainerTransformTile(
                          icon: Icons.help_outline_rounded,
                          title: Tr.help(lang),
                          contentBuilder: (ctx, setModalState, close) =>
                              _buildHelpContent(ctx, setModalState, lang, close),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Botón Cerrar Sesión
                InkWell(
                  onTap: () => _confirmLogout(context, lang),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Tr.logout(lang),
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  // Modal limpio, elegante y nativo estilo iOS/Android moderno pegado al piso
  Widget _buildContainerTransformTile({
    required IconData icon,
    required String title,
    required Widget Function(BuildContext, StateSetter, VoidCallback) contentBuilder,
    Widget? trailingWidget,
  }) {
    return _buildOptionTile(
      icon: icon,
      title: title,
      trailingWidget: trailingWidget,
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          builder: (ctx) {
            return StatefulBuilder(
              builder: (modalContext, setModalState) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                      child: SingleChildScrollView(
                        child: contentBuilder(
                            modalContext, setModalState, () => Navigator.of(ctx).pop()),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailingWidget,
  }) {
    return Material(
      color: Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryNavy, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?trailingWidget,
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
