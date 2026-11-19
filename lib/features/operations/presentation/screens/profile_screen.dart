import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';

/// PANTALLA DE PERFIL (BankOs):
/// - Diseño responsive para iPad y Móvil (ancho centrado y proporcionado).
/// - Modernos Modal Sheets interactivos que reemplazan los diálogos crudos.
/// - Conmutador interactivo de Idioma (Español / Inglés) que actualiza toda la app.
class ProfileScreen extends ConsumerWidget {
  final bool showBackButton;

  const ProfileScreen({
    super.key,
    this.showBackButton = false,
  });

  // =========================================================================
  // 1. MODAL SHEET: DATOS PERSONALES
  // =========================================================================
  void _showPersonalDataSheet(BuildContext context, AppLanguage lang) {
    final isEs = lang == AppLanguage.es;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
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
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  icon: Icons.person_outline_rounded,
                  label: isEs ? 'Nombre completo' : 'Full Name',
                  value: 'Nombre Alerxo',
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.mail_outline_rounded,
                  label: isEs ? 'Correo electrónico' : 'Email Address',
                  value: 'nenrealron@gmail.com',
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.fingerprint_rounded,
                  label: isEs ? 'Identificación / C.C.' : 'Document ID',
                  value: '1098765432 - Colombia',
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.domain_rounded,
                  label: isEs ? 'Tenant Asignado' : 'Assigned Tenant',
                  value: 'tenant_bankos_01 (RLS Activo)',
                  badgeText: isEs ? 'Aislado' : 'Isolated',
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.credit_card_rounded,
                  label: isEs ? 'Cuentas activas del titular' : 'Active Titular Accounts',
                  value: isEs ? '3 cuentas multimoneda' : '3 multi-currency accounts',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. MODAL SHEET: SEGURIDAD
  // =========================================================================
  void _showSecuritySheet(BuildContext context, AppLanguage lang) {
    final isEs = lang == AppLanguage.es;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
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
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  icon: Icons.fingerprint_rounded,
                  label: isEs ? 'Autenticación biométrica' : 'Biometric Auth',
                  value: isEs ? 'FaceID / Huella activa' : 'FaceID / TouchID Active',
                  badgeText: isEs ? 'Activada' : 'Enabled',
                  badgeColor: const Color(0xFF059669),
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.vpn_key_rounded,
                  label: isEs ? 'Token digital BankOs' : 'Digital Token',
                  value: isEs ? 'Sincronizado vía OTP dinámico' : 'Synced via Dynamic OTP',
                  badgeText: isEs ? 'Activo' : 'Active',
                  badgeColor: const Color(0xFF0284C7),
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.lock_outline_rounded,
                  label: isEs ? 'Cifrado de datos y transacciones' : 'Data Encryption',
                  value: 'AES-256 Cloud Ledger RLS',
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.history_toggle_off_rounded,
                  label: isEs ? 'Último acceso a la plataforma' : 'Last Login',
                  value: isEs ? 'Hoy, 08:30 AM (Sesión segura)' : 'Today, 08:30 AM (Secure Session)',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 3. MODAL SHEET: CONFIGURACIÓN E IDIOMA INTERACTIVO
  // =========================================================================
  void _showConfigSheet(BuildContext context, WidgetRef ref, AppLanguage lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, refConsumer, _) {
            final currentLang = refConsumer.watch(localeNotifierProvider);
            final currentIsEs = currentLang == AppLanguage.es;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Container(
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
                                currentIsEs ? 'Configuración' : 'Settings',
                                style: const TextStyle(
                                  color: AppColors.primaryNavy,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // SECCIÓN IDIOMA INTERACTIVO (ESPAÑOL / INGLÉS)
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
                                  currentIsEs
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
                              currentIsEs
                                      ? 'Cambia el idioma para todos los perfiles (Admin y Clientes).'
                                      : 'Change language for all profiles (Admin & Clients).',
                              style: const TextStyle(
                                  color: Color(0xFF64748B), fontSize: 11),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      refConsumer
                                          .read(localeNotifierProvider.notifier)
                                          .setLanguage(AppLanguage.es);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: currentIsEs
                                          ? AppColors.primaryNavy
                                          : Colors.white,
                                      foregroundColor: currentIsEs
                                          ? Colors.white
                                          : AppColors.primaryNavy,
                                      elevation: currentIsEs ? 2 : 0,
                                      side: BorderSide(
                                        color: currentIsEs
                                            ? AppColors.primaryNavy
                                            : const Color(0xFFCBD5E1),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      '🇪🇸 Español',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      refConsumer
                                          .read(localeNotifierProvider.notifier)
                                          .setLanguage(AppLanguage.en);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: !currentIsEs
                                          ? AppColors.primaryNavy
                                          : Colors.white,
                                      foregroundColor: !currentIsEs
                                          ? Colors.white
                                          : AppColors.primaryNavy,
                                      elevation: !currentIsEs ? 2 : 0,
                                      side: BorderSide(
                                        color: !currentIsEs
                                            ? AppColors.primaryNavy
                                            : const Color(0xFFCBD5E1),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      '🇺🇸 English',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.notifications_active_outlined,
                        label: currentIsEs
                            ? 'Notificaciones push en tiempo real'
                            : 'Real-time Push Notifications',
                        value: currentIsEs
                            ? 'Alertas de depósitos y transacciones activas'
                            : 'Active transaction & deposit alerts',
                        badgeText: currentIsEs ? 'Activadas' : 'Enabled',
                        badgeColor: const Color(0xFF059669),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoCard(
                        icon: Icons.currency_exchange_rounded,
                        label: currentIsEs
                            ? 'Divisas preferidas del titular'
                            : 'Preferred Titular Currencies',
                        value: 'COP (Pesos) / USD (Dólares)',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            currentIsEs ? 'Guardar Cambios' : 'Save Changes',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // 4. MODAL SHEET: AYUDA Y SOPORTE
  // =========================================================================
  void _showHelpSheet(BuildContext context, AppLanguage lang) {
    final isEs = lang == AppLanguage.es;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
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
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  icon: Icons.support_agent_rounded,
                  label: isEs ? 'Centro de soporte BankOs' : 'BankOs Support Center',
                  value: 'soporte@bankos.io • 24/7 Activo',
                  badgeText: isEs ? 'En línea' : 'Online',
                  badgeColor: const Color(0xFF059669),
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.question_answer_outlined,
                  label: isEs ? 'Preguntas frecuentes (FAQ)' : 'Frequently Asked Questions',
                  value: isEs
                      ? 'Límites, divisas y seguridad RLS'
                      : 'Limits, currencies & RLS security',
                ),
                const SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.verified_user_outlined,
                  label: isEs ? 'Regulación y Cumplimiento' : 'Regulation & Compliance',
                  value: isEs
                      ? 'Estándar bancario ISO 20022 compliant'
                      : 'Banking standard ISO 20022 compliant',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 5. MODAL SHEET: CONFIRMAR SALIDA
  // =========================================================================
  void _confirmLogout(BuildContext context, AppLanguage lang) {
    final isEs = lang == AppLanguage.es;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
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
                      ? '¿Estás seguro de que deseas salir de tu cuenta BankOS? Deberás ingresar tus credenciales nuevamente.'
                      : 'Are you sure you want to sign out from BankOS? You will need to log in again.',
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
                          context.go('/login');
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

  // =========================================================================
  // SUBWIDGET: TARJETA DE INFORMACIÓN CON ICONO Y BADGE
  // =========================================================================
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
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeNotifierProvider);
    final isEs = lang == AppLanguage.es;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.primaryNavy,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          isEs ? 'Mi perfil' : 'My Profile',
          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              children: [
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
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
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
                const Text(
                  'Nombre Alerxo',
                  style: TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'nenrealron@gmail.com',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 10),

                // Verified Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

                // Options List (Limpio contenedor blanco con bordes redondeados)
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
                  child: Column(
                    children: [
                      _buildOptionTile(
                        icon: Icons.person_outline_rounded,
                        title: Tr.personalData(lang),
                        onTap: () => _showPersonalDataSheet(context, lang),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildOptionTile(
                        icon: Icons.shield_outlined,
                        title: Tr.security(lang),
                        onTap: () => _showSecuritySheet(context, lang),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildOptionTile(
                        icon: Icons.tune_rounded,
                        title: Tr.settings(lang),
                        trailingWidget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                        onTap: () => _showConfigSheet(context, ref, lang),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildOptionTile(
                        icon: Icons.help_outline_rounded,
                        title: Tr.help(lang),
                        onTap: () => _showHelpSheet(context, lang),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Logout Button
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
