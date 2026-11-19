import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../../core/widgets/bank_brand_logo.dart';
import '../../../../core/widgets/language_segmented_switch.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../operations/domain/entities/operation_record_entity.dart';
import '../../../operations/domain/entities/registered_bank_entity.dart';
import '../../../operations/presentation/providers/operations_providers.dart';
import '../../../operations/presentation/providers/operations_state.dart';

/// CONSOLA DE ADMINISTRACIÓN (BankOs):
/// - SuperAdmin (admin@bankos.com): Gestión y aprovisionamiento global de tenants, personalización de marcas y auditoría.
/// - Admin de Banco (Bancolombia, Bogotá, Santander, Nu): Auditoría, Libro Mayor y configuración aislada de su propia entidad.
/// - 100% Bilingüe (Español / Inglés) reactivo en todos los textos.
/// - Perfil institucional limpio y elegante (idéntico a la vista de usuario).
class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _currentNavIndex = 0;

  // Control de Despliegue para Personalización Visual Institucional (Branding)
  // Por defecto OCULTO para mantener la interfaz sobria y limpia como app real
  bool _isBrandingExpanded = false;

  // Parámetros de Personalización Visual Institucional
  String? _selectedBankIdForOps;
  String? _customPrimaryColorHex;
  String? _customAccentColorHex;
  String? _customLogoKey;
  bool _isSavingBranding = false;

  // Creadores de Colores RGB
  int _primaryR = 0;
  int _primaryG = 45;
  int _primaryB = 114;

  int _accentR = 253;
  int _accentG = 218;
  int _accentB = 36;

  bool _initializedRgb = false;

  // Parámetros de Configuración del Tenant
  double _tenantTransferFeePercent = 0.5;
  bool _tenantRequireBiometrics = true;
  bool _enableCoreLedger = true;
  bool _enableTransfers = true;
  bool _enableLoans = true;
  bool _enableFx = true;

  // Controles de Seguridad Institucional (ON / OFF interactivos)
  bool _realTimeAudit = true;
  bool _twoFactorRequired = true;

  // Controladores para Configuración
  final TextEditingController _configFeeCtrl = TextEditingController(text: '0.5');
  final TextEditingController _configLimitCtrl = TextEditingController(text: '10000000');
  final TextEditingController _customLogoUrlCtrl = TextEditingController();
  final TextEditingController _customPrimaryHexCtrl = TextEditingController();
  final TextEditingController _customAccentHexCtrl = TextEditingController();

  // Filtros de Auditoría y Operaciones
  String _selectedAuditFilter = 'Todos';
  String _selectedOpsFilter = 'Todas';

  bool _isSuperAdminUser(dynamic authUser, RegisteredBankEntity currentBank) {
    if (authUser?.email != null && (authUser.email as String).isNotEmpty) {
      return (authUser.email as String).toLowerCase().contains('bankos');
    }
    return currentBank.isGlobal;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoBindAdminBank();
    });
  }

  /// Auto-asocia la entidad y colores correspondientes al administrador según su correo
  void _autoBindAdminBank() {
    final authUser = ref.read(authNotifierProvider).user;
    if (authUser == null) return;
    final email = authUser.email.toLowerCase();
    final opsState = ref.read(operationsNotifierProvider);
    final banks = opsState.banks;

    RegisteredBankEntity? matched;
    if (email.contains('bancolombia') || email.contains('lombia')) {
      matched = banks
          .where((b) =>
              b.code.contains('lombia') ||
              b.name.toLowerCase().contains('bancolombia'))
          .firstOrNull;
    } else if (email.contains('bogota')) {
      matched = banks
          .where((b) =>
              b.code.contains('bogota') ||
              b.name.toLowerCase().contains('bogot'))
          .firstOrNull;
    } else if (email.contains('santander')) {
      matched = banks
          .where((b) =>
              b.code.contains('santander') ||
              b.name.toLowerCase().contains('santander'))
          .firstOrNull;
    } else if (email.contains('nu')) {
      matched = banks
          .where((b) =>
              b.code.contains('nu') ||
              b.name.toLowerCase().contains('nu'))
          .firstOrNull;
    } else if (email.contains('bankos')) {
      matched = banks
          .where((b) => b.isGlobal || b.id == 'bank_bankos_global')
          .firstOrNull;
    }

    if (matched != null && opsState.activeBank?.id != matched.id) {
      ref.read(operationsNotifierProvider.notifier).switchActiveBank(matched);
      setState(() {
        _selectedBankIdForOps = matched!.id;
        _setPrimaryFromHex(matched.primaryColorHex);
        _setAccentFromHex(matched.accentColorHex);
        _customLogoKey = matched.logoKey;
      });
    }
  }

  void _syncRgbIfFirstTime(String primHex, String accHex) {
    if (!_initializedRgb) {
      _setPrimaryFromHex(primHex);
      _setAccentFromHex(accHex);
      _initializedRgb = true;
    }
  }

  void _setPrimaryFromHex(String hex) {
    try {
      final col = Color(int.parse(hex.replaceFirst('#', '0xFF')));
      _primaryR = (col.value >> 16) & 0xFF;
      _primaryG = (col.value >> 8) & 0xFF;
      _primaryB = col.value & 0xFF;
      _customPrimaryColorHex = hex;
      _customPrimaryHexCtrl.text = hex.replaceFirst('#', '');
    } catch (_) {}
  }

  void _setAccentFromHex(String hex) {
    try {
      final col = Color(int.parse(hex.replaceFirst('#', '0xFF')));
      _accentR = (col.value >> 16) & 0xFF;
      _accentG = (col.value >> 8) & 0xFF;
      _accentB = col.value & 0xFF;
      _customAccentColorHex = hex;
      _customAccentHexCtrl.text = hex.replaceFirst('#', '');
    } catch (_) {}
  }

  void _onPrimaryRgbChanged(int r, int g, int b) {
    setState(() {
      _primaryR = r;
      _primaryG = g;
      _primaryB = b;
      final hex =
          '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'
              .toUpperCase();
      _customPrimaryColorHex = hex;
      _customPrimaryHexCtrl.text = hex.replaceFirst('#', '');
    });
  }

  void _onAccentRgbChanged(int r, int g, int b) {
    setState(() {
      _accentR = r;
      _accentG = g;
      _accentB = b;
      final hex =
          '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'
              .toUpperCase();
      _customAccentColorHex = hex;
      _customAccentHexCtrl.text = hex.replaceFirst('#', '');
    });
  }

  @override
  void dispose() {
    _configFeeCtrl.dispose();
    _configLimitCtrl.dispose();
    _customLogoUrlCtrl.dispose();
    _customPrimaryHexCtrl.dispose();
    _customAccentHexCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(operationsNotifierProvider);
    final currentBank = operationsState.currentBank;
    final lang = ref.watch(localeNotifierProvider);
    final authUser = ref.watch(authNotifierProvider).user;

    // Solo el superadmin (admin@bankos.com o banco global) puede aprovisionar nuevos bancos
    final isSuperAdmin = _isSuperAdminUser(authUser, currentBank);

    // Colores institucionales activos de la entidad del administrador
    final bankPrimaryColor = currentBank.primaryColorParsed;
    final bankAccentColor = currentBank.accentColorParsed;

    final navActiveColor = bankPrimaryColor == Colors.black
        ? const Color(0xFF0F172A)
        : bankPrimaryColor;

    // Construcción de pestañas según rol:
    // SuperAdmin: [Crear, Configuración, Auditoría, Operaciones, Perfil]
    // Admin Local de Banco: [Auditoría, Operaciones, Configuración, Perfil]
    final List<Widget> tabViews = isSuperAdmin
        ? [
            _buildCreateAccountsTab(operationsState, currentBank, lang, bankPrimaryColor),
            _buildTenantConfigTab(currentBank, lang, bankPrimaryColor),
            _buildAuditLogsTab(currentBank, lang, bankPrimaryColor),
            _buildInstitutionalOperationsTab(
                operationsState, currentBank, lang, bankPrimaryColor, bankAccentColor),
            _buildAdminProfileTab(currentBank, lang, bankPrimaryColor, bankAccentColor),
          ]
        : [
            _buildAuditLogsTab(currentBank, lang, bankPrimaryColor),
            _buildInstitutionalOperationsTab(
                operationsState, currentBank, lang, bankPrimaryColor, bankAccentColor),
            _buildTenantConfigTab(currentBank, lang, bankPrimaryColor),
            _buildAdminProfileTab(currentBank, lang, bankPrimaryColor, bankAccentColor),
          ];

    final List<BottomNavigationBarItem> navItems = isSuperAdmin
        ? [
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_business_rounded, size: 22),
              label: Tr.adminCreate(lang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.tune_rounded, size: 22),
              label: Tr.adminConfig(lang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.security_rounded, size: 22),
              label: Tr.adminAudit(lang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_rounded, size: 22),
              label: Tr.adminOps(lang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded, size: 22),
              label: Tr.adminProfile(lang),
            ),
          ]
        : [
            BottomNavigationBarItem(
              icon: const Icon(Icons.security_rounded, size: 22),
              label: Tr.adminAudit(lang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_rounded, size: 22),
              label: Tr.adminOps(lang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.tune_rounded, size: 22),
              label: Tr.adminConfig(lang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded, size: 22),
              label: Tr.adminProfile(lang),
            ),
          ];

    final safeNavIndex = _currentNavIndex >= tabViews.length ? 0 : _currentNavIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: IndexedStack(
            index: safeNavIndex,
            children: tabViews,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: BottomNavigationBar(
                currentIndex: safeNavIndex,
                onTap: (index) {
                  setState(() => _currentNavIndex = index);
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                elevation: 0,
                selectedItemColor: navActiveColor,
                unselectedItemColor: const Color(0xFF94A3B8),
                selectedLabelStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                items: navItems,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // ENCABEZADO INSTITUCIONAL LIMPIO (SIN BANNERS NI SUPERADMIN)
  // =========================================================================
  Widget _buildInstitutionalHeader({
    required RegisteredBankEntity bank,
    required Color primaryColor,
    required bool isSuperAdmin,
    required AppLanguage lang,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BankBrandLogo(
                bank: bank,
                size: 28,
                showName: true,
                textColor: primaryColor == Colors.black
                    ? const Color(0xFF0F172A)
                    : primaryColor,
                fontSize: 16,
              ),
            ],
          ),
          // Conmutador rápido de idioma ES / EN
          GestureDetector(
            onTap: () {
              ref.read(localeNotifierProvider.notifier).toggleLanguage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded,
                      size: 14, color: AppColors.primaryNavy),
                  const SizedBox(width: 4),
                  Text(
                    lang == AppLanguage.es ? 'ES' : 'EN',
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. CREAR CUENTAS / BANCOS (TENANTS) - EXCLUSIVO SUPERADMIN
  // =========================================================================
  Widget _buildCreateAccountsTab(
    OperationsState operationsState,
    RegisteredBankEntity currentBank,
    AppLanguage lang,
    Color primaryColor,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstitutionalHeader(
              bank: currentBank,
              primaryColor: primaryColor,
              isSuperAdmin: true,
              lang: lang,
            ),

            Text(
              Tr.adminTitle(lang),
              style: TextStyle(
                color: primaryColor == Colors.black
                    ? const Color(0xFF0F172A)
                    : primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              Tr.adminSubtitle(lang),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 18),

            // Tarjeta Métrica Resumen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildKpiItem(Tr.activeTenants(lang),
                      '${operationsState.banks.length}', const Color(0xFF0284C7)),
                  Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                  _buildKpiItem(Tr.baasVolume(lang), '\$14.2M USD',
                      primaryColor == Colors.black ? const Color(0xFF0F172A) : primaryColor),
                  Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                  _buildKpiItem(Tr.isolation(lang), '100% RLS', const Color(0xFF059669)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botón Principal de Acción (Solo SuperAdmin)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateTenantModal(context, lang, primaryColor),
                icon: const Icon(Icons.add_business_rounded, size: 20),
                label: Text(
                  Tr.createNewBank(lang),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor == Colors.black
                      ? const Color(0xFF0F172A)
                      : primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Lista de Bancos Registrados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Tr.registeredTenants(lang),
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Tr.activeCount(lang, operationsState.banks.length),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: operationsState.banks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final bank = operationsState.banks[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      BankBrandLogo(bank: bank, size: 24, showName: false),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bank.name,
                              style: const TextStyle(
                                color: AppColors.primaryNavy,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tenant: ${bank.tenantId} • ${bank.currency}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          Tr.operational(lang),
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Modal Limpio para Crear Nuevo Banco (Tenant)
  void _showCreateTenantModal(
    BuildContext context,
    AppLanguage lang,
    Color primaryColor,
  ) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final subdomainCtrl = TextEditingController();
    String currency = 'USD';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 44,
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Tr.modalCreateTitle(lang),
                                style: const TextStyle(
                                  color: AppColors.primaryNavy,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: Color(0xFF64748B)),
                                onPressed: () => Navigator.pop(modalCtx),
                              ),
                            ],
                          ),
                          Text(
                            Tr.modalCreateSub(lang),
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 16),

                          Text(Tr.bankNameLabel(lang),
                              style: const TextStyle(
                                  color: AppColors.primaryNavy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: nameCtrl,
                            decoration:
                                _inputDecoration('Ej. NovaPay Colombia, Banco Caribe'),
                            onChanged: (val) {
                              setModalState(() {
                                final clean = val
                                    .toLowerCase()
                                    .replaceAll(RegExp(r'[^a-z0-9]'), '');
                                subdomainCtrl.text =
                                    clean.isNotEmpty ? '$clean.bankos.io' : '';
                                if (codeCtrl.text.isEmpty && val.length >= 3) {
                                  codeCtrl.text =
                                      val.substring(0, 3).toUpperCase();
                                }
                              });
                            },
                          ),

                          const SizedBox(height: 12),

                          Text(Tr.codeLabel(lang),
                              style: const TextStyle(
                                  color: AppColors.primaryNavy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: codeCtrl,
                            decoration:
                                _inputDecoration('Ej. NOVAPAY, CARIBE, ATLAS'),
                          ),

                          const SizedBox(height: 12),

                          Text(Tr.currencyLabel(lang),
                              style: const TextStyle(
                                  color: AppColors.primaryNavy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['USD', 'COP', 'EUR'].map((curr) {
                              final isSel = currency == curr;
                              return ChoiceChip(
                                label: Text(curr),
                                selected: isSel,
                                selectedColor: primaryColor == Colors.black
                                    ? const Color(0xFF0F172A)
                                    : primaryColor,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : AppColors.primaryNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                onSelected: (val) {
                                  if (val) setModalState(() => currency = curr);
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),

                          Text(Tr.subdomainLabel(lang),
                              style: const TextStyle(
                                  color: AppColors.primaryNavy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: subdomainCtrl,
                            decoration:
                                _inputDecoration('Ej. novapay.bankos.io'),
                          ),

                          const SizedBox(height: 14),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.softBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shield_outlined,
                                    color: Color(0xFF059669), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    Tr.isolationInfo(lang),
                                    style: const TextStyle(
                                      color: AppColors.primaryNavy,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                final name = nameCtrl.text.trim();
                                final code = codeCtrl.text.trim().isNotEmpty
                                    ? codeCtrl.text.trim()
                                    : (name.length >= 3
                                        ? name.substring(0, 3).toUpperCase()
                                        : 'BNK');

                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Ingresa el nombre del banco o institución.'),
                                      backgroundColor: Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                final newBank = RegisteredBankEntity(
                                  id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
                                  name: name,
                                  code: code.toUpperCase(),
                                  tenantId: 'tenant_${code.toLowerCase()}',
                                  currency: currency,
                                  isGlobal: false,
                                );

                                ref
                                    .read(operationsNotifierProvider.notifier)
                                    .registerNewTenantBank(newBank);
                                Navigator.pop(modalCtx);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '¡Banco $name creado exitosamente con aislamiento RLS!'),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor == Colors.black
                                    ? const Color(0xFF0F172A)
                                    : primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                Tr.provisionButton(lang),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // 2. MODIFICAR CONFIGURACIONES DEL TENANT
  // =========================================================================
  Widget _buildTenantConfigTab(
    RegisteredBankEntity currentBank,
    AppLanguage lang,
    Color primaryColor,
  ) {
    final authUser = ref.watch(authNotifierProvider).user;
    final isSuperAdmin = _isSuperAdminUser(authUser, currentBank);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstitutionalHeader(
              bank: currentBank,
              primaryColor: primaryColor,
              isSuperAdmin: isSuperAdmin,
              lang: lang,
            ),

            Text(
              Tr.tenantConfig(lang),
              style: TextStyle(
                color: primaryColor == Colors.black
                    ? const Color(0xFF0F172A)
                    : primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              Tr.tenantConfigSubtitle(lang, currentBank.name),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Tr.transferFeeLabel(lang),
                      style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _configFeeCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Ej. 0.5%'),
                  ),

                  const SizedBox(height: 14),

                  Text(Tr.dailyLimitLabel(lang),
                      style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _configLimitCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Ej. 10000000'),
                  ),

                  const SizedBox(height: 14),

                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: primaryColor == Colors.black
                          ? const Color(0xFF0F172A)
                          : primaryColor,
                      title: Text(
                        Tr.requireBiometrics(lang),
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        Tr.requireBiometricsSub(lang),
                        style:
                            const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                      value: _tenantRequireBiometrics,
                      onChanged: (val) {
                        setState(() => _tenantRequireBiometrics = val);
                      },
                    ),
                  ),

                  const Divider(height: 16, color: Color(0xFFF1F5F9)),

                  Text(Tr.enabledModules(lang),
                      style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Core Ledger',
                            style: TextStyle(fontSize: 11)),
                        selected: _enableCoreLedger,
                        onSelected: (val) =>
                            setState(() => _enableCoreLedger = val),
                      ),
                      FilterChip(
                        label: const Text('Transfers & Pagos',
                            style: TextStyle(fontSize: 11)),
                        selected: _enableTransfers,
                        onSelected: (val) =>
                            setState(() => _enableTransfers = val),
                      ),
                      FilterChip(
                        label: const Text('Loans & Créditos',
                            style: TextStyle(fontSize: 11)),
                        selected: _enableLoans,
                        onSelected: (val) =>
                            setState(() => _enableLoans = val),
                      ),
                      FilterChip(
                        label: const Text('FX Multidivisa',
                            style: TextStyle(fontSize: 11)),
                        selected: _enableFx,
                        onSelected: (val) => setState(() => _enableFx = val),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final fee =
                            double.tryParse(_configFeeCtrl.text.trim()) ?? 0.5;
                        setState(() {
                          _tenantTransferFeePercent = fee;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Configuraciones de ${currentBank.name} guardadas correctamente.',
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(
                        Tr.saveTenantConfig(lang),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor == Colors.black
                            ? const Color(0xFF0F172A)
                            : primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
    );
  }

  // =========================================================================
  // 3. AUDITAR LOGS DE SEGURIDAD
  // =========================================================================
  Widget _buildAuditLogsTab(
    RegisteredBankEntity currentBank,
    AppLanguage lang,
    Color primaryColor,
  ) {
    final authUser = ref.watch(authNotifierProvider).user;
    final isSuperAdmin = _isSuperAdminUser(authUser, currentBank);

    final isEs = lang == AppLanguage.es;
    final auditLogs = [
      {
        'event': 'SEC-AUTH-001',
        'title': isEs
            ? 'Autenticación Exitosa Administrador'
            : 'Successful Administrator Authentication',
        'actor': authUser?.name ?? 'Administrador ${currentBank.name}',
        'detail': isEs
            ? 'Acceso autenticado con MFA y token JWT.'
            : 'Access authenticated with MFA and JWT token.',
        'time': isEs ? 'Hace 2 min' : '2 min ago',
        'status': 'OK',
      },
      {
        'event': 'TENANT-CONFIG-002',
        'title': isEs
            ? 'Actualización de Comisión del Tenant'
            : 'Tenant Commission Update',
        'actor': 'Administrador ${currentBank.name}',
        'detail': isEs
            ? 'Comisión de transferencias ajustada a $_tenantTransferFeePercent%.'
            : 'Transfer fee adjusted to $_tenantTransferFeePercent%.',
        'time': isEs ? 'Hace 15 min' : '15 min ago',
        'status': 'INFO',
      },
      {
        'event': 'RLS-GUARD-003',
        'title': isEs
            ? 'Verificación de Aislamiento de Datos RLS'
            : 'RLS Data Isolation Verification',
        'actor': 'BankOs Core Engine',
        'detail': isEs
            ? '100% de consultas aisladas por tenant_id ${currentBank.tenantId}.'
            : '100% queries isolated by tenant_id ${currentBank.tenantId}.',
        'time': isEs ? 'Hace 1 hora' : '1 hour ago',
        'status': 'SECURE',
      },
      {
        'event': 'LEDGER-SETTLE-004',
        'title': isEs
            ? 'Conciliación Automática del Libro Mayor'
            : 'Automatic General Ledger Reconciliation',
        'actor': 'Ledger Settlement Worker',
        'detail': isEs
            ? 'Partidas dobles validadas y conciliadas sin descuadres.'
            : 'Double entry lines verified and reconciled without imbalance.',
        'time': isEs ? 'Hace 3 horas' : '3 hours ago',
        'status': 'OK',
      },
    ];

    final filteredLogs = _selectedAuditFilter == 'Todos'
        ? auditLogs
        : auditLogs.where((l) => l['status'] == _selectedAuditFilter).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstitutionalHeader(
              bank: currentBank,
              primaryColor: primaryColor,
              isSuperAdmin: isSuperAdmin,
              lang: lang,
            ),

            Text(
              Tr.auditTitle(lang),
              style: TextStyle(
                color: primaryColor == Colors.black
                    ? const Color(0xFF0F172A)
                    : primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              Tr.auditSubtitle(lang, currentBank.name),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Chips de Filtro
            Row(
              children: ['Todos', 'OK', 'INFO', 'SECURE'].map((f) {
                final isSel = _selectedAuditFilter == f;
                final label = f == 'Todos' ? Tr.filterAll(lang) : f;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSel,
                    selectedColor: primaryColor == Colors.black
                        ? const Color(0xFF0F172A)
                        : primaryColor,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.primaryNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedAuditFilter = f);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Lista de Logs
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredLogs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = filteredLogs[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.softBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              log['event']!,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              log['status']!,
                              style: const TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        log['title']!,
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        log['detail']!,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${isEs ? 'Por:' : 'By:'} ${log['actor']}',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            log['time']!,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 4. OPERACIONES DE LA INSTITUCIÓN & LIBRO MAYOR
  // =========================================================================
  Widget _buildInstitutionalOperationsTab(
    OperationsState operationsState,
    RegisteredBankEntity currentBank,
    AppLanguage lang,
    Color bankPrimaryColor,
    Color bankAccentColor,
  ) {
    final authUser = ref.watch(authNotifierProvider).user;
    final isSuperAdmin = _isSuperAdminUser(authUser, currentBank);

    // Determinar banco objetivo a gestionar
    final selectedBankId = _selectedBankIdForOps ?? currentBank.id;
    final targetBank = operationsState.banks.firstWhere(
      (b) => b.id == selectedBankId,
      orElse: () => currentBank,
    );

    final activePrimaryHex =
        _customPrimaryColorHex ?? targetBank.primaryColorHex;
    final activeAccentHex =
        _customAccentColorHex ?? targetBank.accentColorHex;
    final activeLogoKey = _customLogoKey ?? targetBank.logoKey;

    _syncRgbIfFirstTime(activePrimaryHex, activeAccentHex);

    final primaryColorParsed =
        Color(int.parse(activePrimaryHex.replaceFirst('#', '0xFF')));
    final accentColorParsed =
        Color(int.parse(activeAccentHex.replaceFirst('#', '0xFF')));

    // Operaciones institucionales reales para el libro mayor del banco objetivo
    final rawBankHistory = _getTransactionsForBank(targetBank, operationsState);

    final filteredHistory = _selectedOpsFilter == 'Todas'
        ? rawBankHistory
        : rawBankHistory.where((h) {
            final t = h.type.toString().toLowerCase();
            if (_selectedOpsFilter == 'Depósitos') return t.contains('deposit');
            if (_selectedOpsFilter == 'Retiros') return t.contains('withdrawal');
            return t.contains('transfer');
          }).toList();

    final double filteredSum =
        filteredHistory.fold(0.0, (acc, item) => acc + item.amount);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstitutionalHeader(
              bank: currentBank,
              primaryColor: bankPrimaryColor,
              isSuperAdmin: isSuperAdmin,
              lang: lang,
            ),

            Text(
              Tr.institutionOps(lang),
              style: TextStyle(
                color: bankPrimaryColor == Colors.black
                    ? const Color(0xFF0F172A)
                    : bankPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              Tr.institutionOpsSubtitle(lang, currentBank.name, isSuperAdmin),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // SECCIÓN: SI ES SUPERADMIN -> MENÚ DESPLEGABLE DE BANCO
            if (isSuperAdmin) ...[
              Text(
                Tr.bankToManage(lang),
                style: const TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // MENÚ DESPLEGABLE DE BANCOS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: operationsState.banks.any((b) => b.id == targetBank.id)
                        ? targetBank.id
                        : (operationsState.banks.isNotEmpty
                            ? operationsState.banks.first.id
                            : null),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_circle_outlined,
                        color: AppColors.brandBlue, size: 22),
                    items: operationsState.banks.map((b) {
                      return DropdownMenuItem<String>(
                        value: b.id,
                        child: Row(
                          children: [
                            BankBrandLogo(bank: b, size: 20, showName: false),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                b.name,
                                style: const TextStyle(
                                  color: AppColors.primaryNavy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.softBackground,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                b.code.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newBankId) {
                      if (newBankId != null) {
                        final b = operationsState.banks
                            .firstWhere((x) => x.id == newBankId);
                        setState(() {
                          _selectedBankIdForOps = b.id;
                          _setPrimaryFromHex(b.primaryColorHex);
                          _setAccentFromHex(b.accentColorHex);
                          _customLogoKey = b.logoKey;
                          _customLogoUrlCtrl.text =
                              b.logoKey.startsWith('http') ? b.logoKey : '';
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // BOTÓN DESPLEGABLE: "PERSONALIZAR MARCA Y COLORES" (SUPERADMIN Y ADMINS DE BANCO)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _isBrandingExpanded = !_isBrandingExpanded);
                },
                  icon: Icon(
                    _isBrandingExpanded
                        ? Icons.tune_rounded
                        : Icons.palette_outlined,
                    color: bankPrimaryColor == Colors.black
                        ? const Color(0xFF0F172A)
                        : bankPrimaryColor,
                    size: 18,
                  ),
                  label: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isBrandingExpanded
                              ? Tr.hideBrand(lang)
                              : Tr.customizeBrand(lang, targetBank.name),
                          style: TextStyle(
                            color: bankPrimaryColor == Colors.black
                                ? const Color(0xFF0F172A)
                                : bankPrimaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        _isBrandingExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: bankPrimaryColor == Colors.black
                            ? const Color(0xFF0F172A)
                            : bankPrimaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: (bankPrimaryColor == Colors.black
                              ? const Color(0xFF0F172A)
                              : bankPrimaryColor)
                          .withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // PANEL DE PERSONALIZACIÓN VISUAL (SOLO SI SE EXPANDIÓ)
              if (_isBrandingExpanded) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.palette_outlined,
                              color: AppColors.brandBlue, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Personalización: ${targetBank.name}',
                              style: const TextStyle(
                                color: AppColors.primaryNavy,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // VISTA PREVIA DE LA TARJETA
                      Container(
                        height: 165,
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColorParsed,
                              primaryColorParsed == Colors.black
                                  ? const Color(0xFF1E293B)
                                  : Color.lerp(
                                      primaryColorParsed, Colors.black, 0.45)!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: accentColorParsed.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColorParsed.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFDF70),
                                        Color(0xFFD4AF37),
                                        Color(0xFF996515),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.contactless_rounded,
                                  color: Colors.white.withValues(alpha: 0.75),
                                  size: 20,
                                ),
                                const Spacer(),
                                Flexible(
                                  child: BankBrandLogo(
                                    bank: targetBank.copyWith(
                                      primaryColorHex: activePrimaryHex,
                                      accentColorHex: activeAccentHex,
                                      logoKey: activeLogoKey,
                                    ),
                                    size: 26,
                                    showName: true,
                                    textColor: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              '••••   ••••   ••••   8821',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    targetBank.name.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: accentColorParsed,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'BANCO',
                                    style: TextStyle(
                                      color: (accentColorParsed == Colors.black ||
                                              accentColorParsed.computeLuminance() < 0.5)
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        Tr.bankLogoLabel(lang),
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: [
                              'bancolombia',
                              'banco-bogota',
                              'banco-santander',
                              'banco-nu',
                              'banco-davivienda',
                              'banco-bbva',
                              'bankos',
                            ].contains(activeLogoKey)
                                ? activeLogoKey
                                : 'custom',
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                  value: 'bancolombia',
                                  child: Text('Bancolombia')),
                              DropdownMenuItem(
                                  value: 'banco-bogota',
                                  child: Text('Banco de Bogotá')),
                              DropdownMenuItem(
                                  value: 'banco-santander',
                                  child: Text('Banco Santander')),
                              DropdownMenuItem(
                                  value: 'banco-nu', child: Text('Banco Nu')),
                              DropdownMenuItem(
                                  value: 'banco-davivienda',
                                  child: Text('Davivienda')),
                              DropdownMenuItem(
                                  value: 'banco-bbva', child: Text('BBVA')),
                              DropdownMenuItem(
                                  value: 'bankos',
                                  child: Text('BankOs Global')),
                              DropdownMenuItem(
                                  value: 'custom',
                                  child:
                                      Text('🔗 Subir / URL Personalizada')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  if (val != 'custom') {
                                    _customLogoKey = val;
                                    _customLogoUrlCtrl.clear();
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customLogoUrlCtrl,
                              decoration: InputDecoration(
                                hintText: Tr.logoHint(lang),
                                hintStyle: const TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 11),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 9),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                              ),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final val = _customLogoUrlCtrl.text.trim();
                              if (val.isNotEmpty) {
                                setState(() => _customLogoKey = val);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Logo personalizado aplicado.'),
                                    backgroundColor: Color(0xFF10B981),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(Tr.applyLogo(lang),
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Text(
                        Tr.primaryColorLabel(lang),
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Tr.colorPaletteInstruction(lang),
                        style:
                            const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          {'hex': '#000000', 'name': 'Negro (Bancolombia)'},
                          {'hex': '#002D72', 'name': 'Bogotá'},
                          {'hex': '#004BB1', 'name': 'Azul Real'},
                          {'hex': '#0052FF', 'name': 'Azul Neón'},
                          {'hex': '#EC0000', 'name': 'Santander'},
                          {'hex': '#ED1C24', 'name': 'Davivienda'},
                          {'hex': '#820AD1', 'name': 'Nu'},
                          {'hex': '#9B3FE6', 'name': 'Violeta'},
                          {'hex': '#059669', 'name': 'Esmeralda'},
                          {'hex': '#10B981', 'name': 'Neón'},
                          {'hex': '#F97316', 'name': 'Naranja'},
                          {'hex': '#FFFFFF', 'name': 'Blanco'},
                        ].map((p) {
                          final isSel = activePrimaryHex.toUpperCase() ==
                              p['hex']!.toUpperCase();
                          final col = Color(
                              int.parse(p['hex']!.replaceFirst('#', '0xFF')));
                          return Tooltip(
                            message: '${p['name']} (${p['hex']})',
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _setPrimaryFromHex(p['hex']!);
                              }),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: col,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel
                                        ? AppColors.brandBlue
                                        : const Color(0xFFCBD5E1),
                                    width: isSel ? 3 : 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: col.withValues(alpha: 0.25),
                                      blurRadius: isSel ? 5 : 2,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isSel
                                    ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: col == Colors.white
                                            ? Colors.black
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(
                                        255, _primaryR, _primaryG, _primaryB),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFFCBD5E1),
                                        width: 1.5),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${Tr.rgbCreatorLabel(lang)} $activePrimaryHex  (R:$_primaryR, G:$_primaryG, B:$_primaryB)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _buildRgbSlider(
                              label: 'R',
                              value: _primaryR,
                              color: Colors.red,
                              onChanged: (val) => _onPrimaryRgbChanged(
                                  val, _primaryG, _primaryB),
                            ),
                            _buildRgbSlider(
                              label: 'G',
                              value: _primaryG,
                              color: Colors.green,
                              onChanged: (val) => _onPrimaryRgbChanged(
                                  _primaryR, val, _primaryB),
                            ),
                            _buildRgbSlider(
                              label: 'B',
                              value: _primaryB,
                              color: Colors.blue,
                              onChanged: (val) => _onPrimaryRgbChanged(
                                  _primaryR, _primaryG, val),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        Tr.accentColorLabel(lang),
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Tr.colorPaletteInstruction(lang),
                        style:
                            const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          {'hex': '#FDDA24', 'name': 'Amarillo Oro (Bancolombia)'},
                          {'hex': '#0052FF', 'name': 'Azul Eléctrico'},
                          {'hex': '#10B981', 'name': 'Verde Neón'},
                          {'hex': '#EC0000', 'name': 'Rojo'},
                          {'hex': '#9B3FE6', 'name': 'Violeta'},
                          {'hex': '#F97316', 'name': 'Naranja'},
                          {'hex': '#06B6D4', 'name': 'Cyan'},
                          {'hex': '#EC4899', 'name': 'Rosa'},
                          {'hex': '#000000', 'name': 'Negro'},
                          {'hex': '#FFFFFF', 'name': 'Blanco'},
                        ].map((p) {
                          final isSel = activeAccentHex.toUpperCase() ==
                              p['hex']!.toUpperCase();
                          final col = Color(
                              int.parse(p['hex']!.replaceFirst('#', '0xFF')));
                          return Tooltip(
                            message: '${p['name']} (${p['hex']})',
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _setAccentFromHex(p['hex']!);
                              }),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: col,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel
                                        ? AppColors.brandBlue
                                        : const Color(0xFFCBD5E1),
                                    width: isSel ? 3 : 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: col.withValues(alpha: 0.25),
                                      blurRadius: isSel ? 5 : 2,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isSel
                                    ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: col == Colors.white ||
                                                col == const Color(0xFFFDDA24)
                                            ? Colors.black
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(
                                        255, _accentR, _accentG, _accentB),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFFCBD5E1),
                                        width: 1.5),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${Tr.rgbCreatorLabel(lang)} $activeAccentHex  (R:$_accentR, G:$_accentG, B:$_accentB)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _buildRgbSlider(
                              label: 'R',
                              value: _accentR,
                              color: Colors.red,
                              onChanged: (val) => _onAccentRgbChanged(
                                  val, _accentG, _accentB),
                            ),
                            _buildRgbSlider(
                              label: 'G',
                              value: _accentG,
                              color: Colors.green,
                              onChanged: (val) => _onAccentRgbChanged(
                                  _accentR, val, _accentB),
                            ),
                            _buildRgbSlider(
                              label: 'B',
                              value: _accentB,
                              color: Colors.blue,
                              onChanged: (val) => _onAccentRgbChanged(
                                  _accentR, _accentG, val),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // BOTÓN GUARDAR IDENTIDAD DE MARCA
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isSavingBranding
                              ? null
                              : () async {
                                  setState(() => _isSavingBranding = true);
                                  await ref
                                      .read(operationsNotifierProvider.notifier)
                                      .updateBankBranding(
                                        bankId: targetBank.id,
                                        primaryColorHex: activePrimaryHex,
                                        accentColorHex: activeAccentHex,
                                        logoKey: activeLogoKey,
                                      );
                                  setState(() => _isSavingBranding = false);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '¡Marca de ${targetBank.name} guardada en PostgreSQL y aplicada con éxito!',
                                        ),
                                        backgroundColor:
                                            const Color(0xFF10B981),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                },
                          icon: _isSavingBranding
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 18),
                          label: Text(
                            _isSavingBranding
                                ? Tr.saving(lang)
                                : Tr.saveBrandIdentity(lang),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

            // SECCIÓN: LIBRO MAYOR DE OPERACIONES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    Tr.ledgerTitle(lang, targetBank.name),
                    style: TextStyle(
                      color: bankPrimaryColor == Colors.black
                          ? const Color(0xFF0F172A)
                          : bankPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  Tr.conciliatedBadge(lang),
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tira métrica dinámica
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(
                    Tr.totalRecords(lang),
                    '${filteredHistory.length} ops',
                    valueColor: bankPrimaryColor == Colors.black
                        ? const Color(0xFF0F172A)
                        : bankPrimaryColor,
                  ),
                  Container(width: 1, height: 26, color: const Color(0xFFCBD5E1)),
                  _buildMetric(
                    Tr.totalAmount(lang),
                    _formatLedgerAmount(filteredSum, targetBank.currency),
                    valueColor: const Color(0xFF059669),
                  ),
                  Container(width: 1, height: 26, color: const Color(0xFFCBD5E1)),
                  _buildMetric(
                    Tr.baseCurrency(lang),
                    targetBank.currency,
                    valueColor: AppColors.primaryNavy,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Filtros de Operación Interactivos
            Row(
              children: ['Todas', 'Depósitos', 'Retiros', 'Transferencias'].map((f) {
                final isSel = _selectedOpsFilter == f;
                String chipLabel;
                if (f == 'Todas') {
                  chipLabel = Tr.filterOpsAll(lang);
                } else if (f == 'Depósitos') {
                  chipLabel = Tr.filterDeposits(lang);
                } else if (f == 'Retiros') {
                  chipLabel = Tr.filterWithdrawals(lang);
                } else {
                  chipLabel = Tr.filterTransfers(lang);
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(chipLabel),
                    selected: isSel,
                    selectedColor: bankPrimaryColor == Colors.black
                        ? const Color(0xFF0F172A)
                        : bankPrimaryColor,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.primaryNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedOpsFilter = f);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Lista animada de transacciones
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey('ledger_${targetBank.id}_$_selectedOpsFilter'),
                child: filteredHistory.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            Tr.noOpsTenant(lang),
                            style: const TextStyle(
                                color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredHistory.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = filteredHistory[index];
                          final isDeposit =
                              item.type == OperationType.deposit;
                          final isWithdrawal =
                              item.type == OperationType.withdrawal;

                          final iconData = isDeposit
                              ? Icons.arrow_downward_rounded
                              : (isWithdrawal
                                  ? Icons.arrow_upward_rounded
                                  : Icons.swap_horiz_rounded);

                          final iconBg = isDeposit
                              ? const Color(0xFFDCFCE7)
                              : (isWithdrawal
                                  ? const Color(0xFFFEE2E8)
                                  : const Color(0xFFEFF6FF));

                          final iconColor = isDeposit
                              ? const Color(0xFF16A34A)
                              : (isWithdrawal
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF2563EB));

                          final amountPrefix = isDeposit ? '+' : '-';
                          final amountColor = isDeposit
                              ? const Color(0xFF16A34A)
                              : (isWithdrawal
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF0F172A));

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(iconData,
                                      color: iconColor, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          color: AppColors.primaryNavy,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.description,
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '$amountPrefix${item.formattedAmount}',
                                  style: TextStyle(
                                    color: amountColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 5. PERFIL DEL ADMINISTRADOR (DISEÑO IDÉNTICO Y ELEGANTE DE FOTO 4 / 5)
  // =========================================================================
  Widget _buildAdminProfileTab(
    RegisteredBankEntity currentBank,
    AppLanguage lang,
    Color bankPrimaryColor,
    Color bankAccentColor,
  ) {
    final authUser = ref.watch(authNotifierProvider).user;
    final isSuperAdmin = _isSuperAdminUser(authUser, currentBank);
    final adminName = authUser?.name ??
        (isSuperAdmin ? 'Luigui Garizado' : 'Administrador ${currentBank.name}');
    final adminEmail = authUser?.email ??
        (isSuperAdmin
            ? 'admin@bankos.com'
            : 'admin@${currentBank.code.toLowerCase()}.com');

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            // Título Centrado: "My Profile" / "Mi Perfil"
            Center(
              child: Text(
                Tr.myProfile(lang),
                style: const TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Avatar Circular Centrado con Ícono de Editar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Color(0xFF64748B),
                        size: 48,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 26,
                      height: 26,
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

            // Nombre Completo y Correo
            Text(
              adminName,
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              adminEmail,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Pastilla "Verified Account" / "Cuenta Verificada"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF16A34A), size: 14),
                  const SizedBox(width: 5),
                  Text(
                    Tr.verifiedAccount(lang),
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Tarjeta de Opciones del Menú (Exacto Mockup Imagen 5)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileMenuTile(
                    icon: Icons.badge_outlined,
                    title: Tr.institutionalData(lang),
                    onTap: () => _showInstitutionalDataModal(
                        context, lang, currentBank, isSuperAdmin, bankPrimaryColor),
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                  _buildProfileMenuTile(
                    icon: Icons.shield_outlined,
                    title: Tr.security(lang),
                    onTap: () => _showSecurityControlsModal(
                        context, lang, bankPrimaryColor),
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                  _buildProfileMenuTile(
                    icon: Icons.tune_rounded,
                    title: Tr.settings(lang),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lang == AppLanguage.es ? 'ES / EN' : 'EN / ES',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => _showSettingsModal(context, lang),
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                  _buildProfileMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: Tr.help(lang),
                    onTap: () => _showHelpModal(context, lang),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Botón de Cerrar Sesión
            InkWell(
              onTap: () => _confirmLogout(context, lang),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        trailing: trailing ??
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
      ),
    );
  }

  // =========================================================================
  // MODALES LIMPIOS DEL PERFIL INSTITUCIONAL
  // =========================================================================
  void _showInstitutionalDataModal(
    BuildContext context,
    AppLanguage lang,
    RegisteredBankEntity bank,
    bool isSuperAdmin,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
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
                      Text(
                        Tr.institutionalData(lang),
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Tr.idBadge(lang), 'ADM-88392-COL',
                      badge: Tr.verified(lang)),
                  _buildDetailRow(Tr.assignedEntity(lang),
                      isSuperAdmin ? 'BankOs Core' : bank.name),
                  _buildDetailRow(
                      Tr.tenantIdLabel(lang),
                      isSuperAdmin
                          ? 'bank_bankos_global'
                          : bank.tenantId),
                  _buildDetailRow(Tr.accessLevel(lang),
                      isSuperAdmin ? Tr.totalAccess(lang) : Tr.institutionalAccess(lang)),
                  _buildDetailRow(Tr.dataIsolation(lang),
                      Tr.dedicatedSchemaValue(lang)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(Tr.close(lang),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSecurityControlsModal(
    BuildContext context,
    AppLanguage lang,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
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
                          Text(
                            Tr.securityControlsTitle(lang),
                            style: const TextStyle(
                              color: AppColors.primaryNavy,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSecuritySwitchCard(
                        icon: Icons.assignment_turned_in_outlined,
                        title: Tr.realTimeAuditTitle(lang),
                        subtitle: Tr.realTimeAuditSub(lang),
                        badgeText: _realTimeAudit
                            ? Tr.activeStatus(lang)
                            : Tr.pausedStatus(lang),
                        value: _realTimeAudit,
                        activeColor: AppColors.primaryNavy,
                        onChanged: (val) {
                          setModalState(() => _realTimeAudit = val);
                          setState(() => _realTimeAudit = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSecuritySwitchCard(
                        icon: Icons.smartphone_rounded,
                        title: Tr.twoFaTitle(lang),
                        subtitle: Tr.twoFaSub(lang),
                        badgeText: _twoFactorRequired
                            ? Tr.requiredStatus(lang)
                            : Tr.optionalStatus(lang),
                        value: _twoFactorRequired,
                        activeColor: AppColors.primaryNavy,
                        onChanged: (val) {
                          setModalState(() => _twoFactorRequired = val);
                          setState(() => _twoFactorRequired = val);
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(Tr.save(lang),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
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

  void _showSettingsModal(BuildContext context, AppLanguage lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
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
                  Text(
                    Tr.systemLanguage(lang),
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Tr.systemLanguageSub(lang),
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const LanguageSegmentedSwitch(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(Tr.close(lang),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHelpModal(BuildContext context, AppLanguage lang) {
    final isEs = lang == AppLanguage.es;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
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
                  Text(
                    Tr.help(lang),
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                      isEs ? 'Mesa de Ayuda' : 'Help Desk', 'soporte@bankos.com'),
                  _buildDetailRow(
                      isEs ? 'Documentación BaaS' : 'BaaS Documentation', 'docs.bankos.io'),
                  _buildDetailRow(
                      isEs ? 'Disponibilidad Core' : 'Core SLA', '99.99% Uptime'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(Tr.close(lang),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {String? badge}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 4,
              child: Text(
                label,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Color(0xFF16A34A),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER PARA TRANSACCIONES REALISTAS POR BANCO
  // =========================================================================
  List<OperationRecordEntity> _getTransactionsForBank(
    RegisteredBankEntity targetBank,
    OperationsState operationsState,
  ) {
    final accIds = operationsState.accounts
        .where((a) =>
            a.tenantId == targetBank.tenantId ||
            (targetBank.code.isNotEmpty &&
                a.tenantId.contains(targetBank.code.toLowerCase())))
        .map((a) => a.id)
        .toSet();

    final matchingHistory = operationsState.history.where((h) {
      return accIds.contains(h.originAccountId) ||
          accIds.contains(h.destinationAccountId);
    }).toList();

    if (matchingHistory.isNotEmpty) return matchingHistory;

    final now = DateTime.now();
    final slug = targetBank.code.toLowerCase();

    if (slug.contains('lombia')) {
      return [
        OperationRecordEntity(
          id: 'col_tx_01',
          type: OperationType.deposit,
          title: 'Depósito Nómina Corporativa',
          description: 'Abono quincenal nómina empresarial Tech Corp',
          amount: 4500000.0,
          currency: 'COP',
          timestamp: now.subtract(const Duration(minutes: 25)),
          originAccountId: 'acc_01',
        ),
        OperationRecordEntity(
          id: 'col_tx_02',
          type: OperationType.withdrawal,
          title: 'Retiro Cajero Automático',
          description: 'Dispensación en Cajero Servibanca Unicentro',
          amount: 350000.0,
          currency: 'COP',
          timestamp: now.subtract(const Duration(hours: 2)),
          originAccountId: 'acc_01',
        ),
        OperationRecordEntity(
          id: 'col_tx_03',
          type: OperationType.internalTransfer,
          title: 'Transferencia ACH Transfiya',
          description: 'Envío interbancario a cuenta titular',
          amount: 1200000.0,
          currency: 'COP',
          timestamp: now.subtract(const Duration(hours: 5)),
          originAccountId: 'acc_01',
        ),
        OperationRecordEntity(
          id: 'col_tx_04',
          type: OperationType.deposit,
          title: 'Pago Factura Proveedores',
          description: 'Transferencia recibida por servicios consultoría',
          amount: 2800000.0,
          currency: 'COP',
          timestamp: now.subtract(const Duration(days: 1)),
          originAccountId: 'acc_01',
        ),
      ];
    } else if (slug.contains('bogota') || slug.contains('bogot')) {
      return [
        OperationRecordEntity(
          id: 'bog_tx_01',
          type: OperationType.deposit,
          title: 'Liquidación Fondos Fiduciaria',
          description: 'Rendimiento fiduciario Fiduciaria Bogotá',
          amount: 3000000.0,
          currency: 'COP',
          timestamp: now.subtract(const Duration(minutes: 50)),
          originAccountId: 'acc_bogota_01',
        ),
        OperationRecordEntity(
          id: 'bog_tx_02',
          type: OperationType.withdrawal,
          title: 'Retiro Cajero Red AVAL',
          description: 'Retiro sin tarjeta con token OTP móvil',
          amount: 200000.0,
          currency: 'COP',
          timestamp: now.subtract(const Duration(hours: 4)),
          originAccountId: 'acc_bogota_01',
        ),
        OperationRecordEntity(
          id: 'bog_tx_03',
          type: OperationType.internalTransfer,
          title: 'Transferencia Pago Servicios Públicos',
          description: 'Pago mensual acueducto y energía Bogotá',
          amount: 450000.0,
          currency: 'COP',
          timestamp: now.subtract(const Duration(days: 1)),
          originAccountId: 'acc_bogota_01',
        ),
      ];
    } else if (slug.contains('santander')) {
      return [
        OperationRecordEntity(
          id: 'san_tx_01',
          type: OperationType.deposit,
          title: 'Remesa Internacional SWIFT',
          description: 'Abono directo cuenta Santander International',
          amount: 2500.0,
          currency: 'USD',
          timestamp: now.subtract(const Duration(hours: 1)),
          originAccountId: 'acc_santander_01',
        ),
        OperationRecordEntity(
          id: 'san_tx_02',
          type: OperationType.internalTransfer,
          title: 'Transferencia Comercio Exterior',
          description: 'Pago proveedor insumos Florida',
          amount: 850.0,
          currency: 'USD',
          timestamp: now.subtract(const Duration(hours: 6)),
          originAccountId: 'acc_santander_01',
        ),
        OperationRecordEntity(
          id: 'san_tx_03',
          type: OperationType.withdrawal,
          title: 'Retiro Cajero Santander Global',
          description: 'Dispensación efectivo ATM internacional',
          amount: 300.0,
          currency: 'USD',
          timestamp: now.subtract(const Duration(days: 1)),
          originAccountId: 'acc_santander_01',
        ),
      ];
    } else if (slug.contains('nu')) {
      return [
        OperationRecordEntity(
          id: 'nu_tx_01',
          type: OperationType.deposit,
          title: 'Recarga PSE Cuenta Nu',
          description: 'Abono instantáneo desde portal de pagos PSE',
          amount: 1200000.0,
          currency: 'COP',
          timestamp: now.subtract(const Duration(minutes: 30)),
          originAccountId: 'acc_nu_01',
        ),
        OperationRecordEntity(
          id: 'nu_tx_02',
          type: OperationType.withdrawal,
          title: 'Retiro Cajero Servibanca',
          description: 'Retiro débito en red aliada Nu',
          amount: 150000.0,
          currency: 'COP',
          timestamp: now.subtract(const Duration(hours: 3)),
          originAccountId: 'acc_nu_01',
        ),
        OperationRecordEntity(
          id: 'nu_tx_03',
          type: OperationType.deposit,
          title: 'Rendimiento Cajita Nu 13% E.A.',
          description: 'Interés diario acreditado en cajita de ahorros',
          amount: 85000.0,
          currency: 'COP',
          timestamp: now.subtract(const Duration(hours: 12)),
          originAccountId: 'acc_nu_01',
        ),
      ];
    }

    // Default: Cuenta Global BankOs (BaaS)
    return [
      OperationRecordEntity(
        id: 'bos_tx_01',
        type: OperationType.deposit,
        title: 'Capitalización BaaS Multi-tenant',
        description: 'Aporte de liquidez centralizada para operaciones interbancarias',
        amount: 50000.0,
        currency: 'USD',
        timestamp: now.subtract(const Duration(minutes: 40)),
        originAccountId: 'acc_bankos_01',
      ),
      OperationRecordEntity(
        id: 'bos_tx_02',
        type: OperationType.internalTransfer,
        title: 'Liquidación Compensación ACH',
        description: 'Transferencia de compensación interbancaria Banco de Bogotá',
        amount: 12500.0,
        currency: 'USD',
        timestamp: now.subtract(const Duration(hours: 3)),
        originAccountId: 'acc_bankos_01',
      ),
      OperationRecordEntity(
        id: 'bos_tx_03',
        type: OperationType.deposit,
        title: 'Recarga Gateway API Developer',
        description: 'Cobro de facturación de microservicios BaaS API',
        amount: 8400.0,
        currency: 'USD',
        timestamp: now.subtract(const Duration(hours: 7)),
        originAccountId: 'acc_bankos_01',
      ),
      OperationRecordEntity(
        id: 'bos_tx_04',
        type: OperationType.withdrawal,
        title: 'Retiro Arbitraje Forex',
        description: 'Desembolso hacia tesorería internacional',
        amount: 3200.0,
        currency: 'USD',
        timestamp: now.subtract(const Duration(days: 1)),
        originAccountId: 'acc_bankos_01',
      ),
    ];
  }

  String _formatLedgerAmount(double amount, String currency) {
    final sym = currency == 'EUR' ? '€' : '\$';
    if (amount >= 1000000) {
      final millions = (amount / 1000000).toStringAsFixed(1);
      return '$sym${millions}M $currency';
    } else if (amount >= 1000) {
      final thousands = (amount / 1000).toStringAsFixed(0);
      return '$sym${thousands}K $currency';
    }
    return '$sym${amount.toStringAsFixed(0)} $currency';
  }

  // =========================================================================
  // WIDGETS AUXILIARES
  // =========================================================================
  Widget _buildSecuritySwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, color: activeColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: value
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: value
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF64748B),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            activeTrackColor: activeColor.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.primaryNavy,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: AppColors.primaryNavy),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLanguage lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          Tr.logoutConfirm(lang),
          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          Tr.logoutAdminMessage(lang),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Tr.cancel(lang),
                style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/select-tenant');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(Tr.logout(lang),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRgbSlider({
    required String label,
    required int value,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                thumbColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              ),
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: 255,
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
