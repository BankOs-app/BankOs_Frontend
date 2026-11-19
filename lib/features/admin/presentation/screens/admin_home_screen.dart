import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../../core/widgets/bankos_logo.dart';
import '../../../operations/domain/entities/registered_bank_entity.dart';
import '../../../operations/presentation/providers/operations_providers.dart';
import '../../../operations/presentation/providers/operations_state.dart';

/// PERFIL ADMINISTRADOR (BankOs):
/// 1. Crear cuentas / aprovisionar bancos (tenants)
/// 2. Modificar configuraciones del tenant
/// 3. Auditar logs de seguridad y trazabilidad
/// 4. Consultar todas las operaciones de la institución
/// 5. Perfil del Administrador
class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _currentNavIndex = 0;

  // Parámetros de Configuración del Tenant
  double _tenantTransferFeePercent = 0.5;
  bool _tenantRequireBiometrics = true;
  bool _enableCoreLedger = true;
  bool _enableTransfers = true;
  bool _enableLoans = true;
  bool _enableFx = true;

  // Controladores para Configuración
  final TextEditingController _configFeeCtrl = TextEditingController(text: '0.5');
  final TextEditingController _configLimitCtrl = TextEditingController(text: '10000000');

  // Filtros de Auditoría y Operaciones
  String _selectedAuditFilter = 'Todos';
  String _selectedOpsFilter = 'Todas';

  @override
  void dispose() {
    _configFeeCtrl.dispose();
    _configLimitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(operationsNotifierProvider);
    final currentBank = operationsState.currentBank;
    final lang = ref.watch(localeNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: IndexedStack(
            index: _currentNavIndex,
            children: [
              // Botón 1: Crear cuentas / Bancos (Tenants)
              _buildCreateAccountsTab(operationsState, currentBank, lang),

              // Botón 2: Modificar configuraciones del tenant
              _buildTenantConfigTab(currentBank, lang),

              // Botón 3: Auditar logs
              _buildAuditLogsTab(currentBank, lang),

              // Botón 4: Consultar todas las operaciones de la institución
              _buildInstitutionalOperationsTab(operationsState, currentBank, lang),

              // Botón 5: Perfil del Administrador
              _buildAdminProfileTab(currentBank, lang),
            ],
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
                currentIndex: _currentNavIndex,
                onTap: (index) {
                  setState(() => _currentNavIndex = index);
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                elevation: 0,
                selectedItemColor: AppColors.primaryNavy,
                unselectedItemColor: const Color(0xFF94A3B8),
                selectedLabelStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                items: [
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 1. BOTÓN: CREAR CUENTAS / BANCOS (TENANTS) - ENTRADA LIMPIA Y ELEGANTE
  // =========================================================================
  Widget _buildCreateAccountsTab(OperationsState operationsState,
      RegisteredBankEntity currentBank, AppLanguage lang) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo limpio sin banners
            const BankOsLogo(
              iconSize: 24,
              fontSize: 18,
              textColor: AppColors.primaryNavy,
            ),
            const SizedBox(height: 18),

            Text(
              Tr.adminTitle(lang),
              style: const TextStyle(
                color: AppColors.primaryNavy,
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

            // Tarjeta Métrica Resumen (Limpia, Fondo Suave Figma)
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
                  _buildKpiItem(Tr.activeTenants(lang), '${operationsState.banks.length}', const Color(0xFF0284C7)),
                  Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                  _buildKpiItem(Tr.baasVolume(lang), '\$14.2M USD', AppColors.primaryNavy),
                  Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                  _buildKpiItem(Tr.isolation(lang), '100% RLS', const Color(0xFF059669)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botón Principal de Acción (Azul Marino #031F48 Figma)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateTenantModal(context, lang),
                icon: const Icon(Icons.add_business_rounded, size: 20),
                label: Text(
                  Tr.createNewBank(lang),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Lista de Bancos / Tenants Registrados
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_rounded,
                            color: Color(0xFF2563EB), size: 20),
                      ),
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

  /// Modal Limpio para Crear Nuevo Banco (Tenant) sin desbordes
  void _showCreateTenantModal(BuildContext context, AppLanguage lang) {
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
                                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                                onPressed: () => Navigator.pop(modalCtx),
                              ),
                            ],
                          ),
                          Text(
                            Tr.modalCreateSub(lang),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                            decoration: _inputDecoration('Ej. NovaPay Colombia, Banco Caribe'),
                            onChanged: (val) {
                              setModalState(() {
                                final clean = val.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
                                subdomainCtrl.text = clean.isNotEmpty ? '$clean.bankos.io' : '';
                                if (codeCtrl.text.isEmpty && val.length >= 3) {
                                  codeCtrl.text = val.substring(0, 3).toUpperCase();
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
                            decoration: _inputDecoration('Ej. NOVAPAY, CARIBE, ATLAS'),
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
                                selectedColor: AppColors.primaryNavy,
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
                      decoration: _inputDecoration('Ej. novapay.bankos.io'),
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
                          const Icon(Icons.shield_outlined, color: Color(0xFF059669), size: 18),
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
                              : (name.length >= 3 ? name.substring(0, 3).toUpperCase() : 'BNK');

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingresa el nombre del banco o institución.'),
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

                          ref.read(operationsNotifierProvider.notifier).registerNewTenantBank(newBank);
                          Navigator.pop(modalCtx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('¡Banco $name creado exitosamente con aislamiento RLS!'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          Tr.provisionButton(lang),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
  // 2. BOTÓN: MODIFICAR CONFIGURACIONES DEL TENANT
  // =========================================================================
  Widget _buildTenantConfigTab(RegisteredBankEntity currentBank, AppLanguage lang) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BankOsLogo(
              iconSize: 24,
              fontSize: 18,
              textColor: AppColors.primaryNavy,
            ),
            const SizedBox(height: 18),

            Text(
              Tr.tenantConfig(lang),
              style: const TextStyle(
                color: AppColors.primaryNavy,
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.primaryNavy,
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
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                    value: _tenantRequireBiometrics,
                    onChanged: (val) {
                      setState(() => _tenantRequireBiometrics = val);
                    },
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
                        label: const Text('Core Ledger', style: TextStyle(fontSize: 11)),
                        selected: _enableCoreLedger,
                        onSelected: (val) => setState(() => _enableCoreLedger = val),
                      ),
                      FilterChip(
                        label: const Text('Transfers & Pagos', style: TextStyle(fontSize: 11)),
                        selected: _enableTransfers,
                        onSelected: (val) => setState(() => _enableTransfers = val),
                      ),
                      FilterChip(
                        label: const Text('Loans & Créditos', style: TextStyle(fontSize: 11)),
                        selected: _enableLoans,
                        onSelected: (val) => setState(() => _enableLoans = val),
                      ),
                      FilterChip(
                        label: const Text('FX Multidivisa', style: TextStyle(fontSize: 11)),
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
                        final fee = double.tryParse(_configFeeCtrl.text.trim()) ?? 0.5;
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 3. BOTÓN: AUDITAR LOGS
  // =========================================================================
  Widget _buildAuditLogsTab(RegisteredBankEntity currentBank, AppLanguage lang) {
    final auditLogs = [
      {
        'event': 'SEC-AUTH-001',
        'title': 'Autenticación Exitosa Super-Admin',
        'actor': 'Luigui Garizado (ADM-88392)',
        'detail': 'Acceso autenticado con MFA y token JWT.',
        'time': 'Hace 2 min',
        'status': 'OK',
      },
      {
        'event': 'TENANT-CONFIG-002',
        'title': 'Actualización de Comisión del Tenant',
        'actor': 'Super-Admin',
        'detail': 'Comisión de transferencias ajustada a $_tenantTransferFeePercent%.',
        'time': 'Hace 15 min',
        'status': 'INFO',
      },
      {
        'event': 'RLS-GUARD-003',
        'title': 'Verificación de Aislamiento de Datos RLS',
        'actor': 'Motor BankOs Core',
        'detail': '100% de consultas aisladas por tenant_id validado.',
        'time': 'Hace 1 hora',
        'status': 'SECURE',
      },
      {
        'event': 'LEDGER-SETTLE-004',
        'title': 'Conciliación Automática del Libro Mayor',
        'actor': 'Ledger Settlement Worker',
        'detail': 'Partidas dobles validadas y conciliadas sin descuadres.',
        'time': 'Hace 3 horas',
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
            const BankOsLogo(
              iconSize: 24,
              fontSize: 18,
              textColor: AppColors.primaryNavy,
            ),
            const SizedBox(height: 18),

            Text(
              Tr.auditTitle(lang),
              style: const TextStyle(
                color: AppColors.primaryNavy,
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
                    selectedColor: AppColors.primaryNavy,
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
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            'Por: ${log['actor']}',
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
  // 4. BOTÓN: CONSULTAR TODAS LAS OPERACIONES DE LA INSTITUCIÓN
  // =========================================================================
  Widget _buildInstitutionalOperationsTab(OperationsState operationsState,
      RegisteredBankEntity currentBank, AppLanguage lang) {
    final history = operationsState.activeTenantHistory;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BankOsLogo(
              iconSize: 24,
              fontSize: 18,
              textColor: AppColors.primaryNavy,
            ),
            const SizedBox(height: 18),

            Text(
              Tr.institutionOps(lang),
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              Tr.ledgerGeneral(lang, currentBank.name),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Tira métrica
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(Tr.totalRecords(lang), '${history.length} ops'),
                  Container(width: 1, height: 26, color: const Color(0xFFCBD5E1)),
                  _buildMetric(Tr.status(lang), Tr.conciliated(lang)),
                  Container(width: 1, height: 26, color: const Color(0xFFCBD5E1)),
                  _buildMetric(Tr.baseCurrency(lang), currentBank.currency),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filtros de Operación
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
                    selectedColor: AppColors.primaryNavy,
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

            // Lista de transacciones del libro mayor
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    Tr.noOpsTenant(lang),
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = history[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.receipt_long_rounded,
                              color: Color(0xFF2563EB), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: AppColors.primaryNavy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                          item.formattedAmount,
                          style: const TextStyle(
                            color: AppColors.primaryNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
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

  // =========================================================================
  // 5. BOTÓN: PERFIL DEL ADMINISTRADOR
  // =========================================================================
  Widget _buildAdminProfileTab(RegisteredBankEntity currentBank, AppLanguage lang) {
    final isEs = lang == AppLanguage.es;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BankOsLogo(
              iconSize: 24,
              fontSize: 18,
              textColor: AppColors.primaryNavy,
            ),
            const SizedBox(height: 18),

            Text(
              Tr.adminProfileTitle(lang),
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              Tr.adminProfileSub(lang),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 18),

            // Tarjeta de Identidad del Administrador
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.softBackground,
                          border: Border.all(color: AppColors.primaryNavy, width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.admin_panel_settings_rounded,
                              color: AppColors.primaryNavy, size: 26),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Luigui Garizado',
                              style: TextStyle(
                                color: AppColors.primaryNavy,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              Tr.adminRole(lang),
                              style: const TextStyle(
                                color: Color(0xFF0284C7),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'admin@bankos.com',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildProfileRow(Tr.idBadge(lang), 'ADM-88392-COL'),
                  const SizedBox(height: 8),
                  _buildProfileRow(Tr.assignedEntity(lang), currentBank.name),
                  const SizedBox(height: 8),
                  _buildProfileRow(Tr.tenantIdLabel(lang), currentBank.id),
                  const SizedBox(height: 8),
                  _buildProfileRow(Tr.activeRegion(lang), 'US-East / LATAM Primary'),
                  const SizedBox(height: 8),
                  _buildProfileRow(Tr.accessLevel(lang), 'Super-Admin Cloud BaaS'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Conmutador de Idioma del Sistema (Español / Inglés)
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
                  Row(
                    children: [
                      const Icon(Icons.language_rounded,
                          color: AppColors.primaryNavy, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        Tr.systemLanguage(lang),
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
                    Tr.systemLanguageSub(lang),
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(localeNotifierProvider.notifier)
                                .setLanguage(AppLanguage.es);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEs
                                ? AppColors.primaryNavy
                                : Colors.white,
                            foregroundColor: isEs
                                ? Colors.white
                                : AppColors.primaryNavy,
                            elevation: isEs ? 2 : 0,
                            side: BorderSide(
                              color: isEs
                                  ? AppColors.primaryNavy
                                  : const Color(0xFFCBD5E1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '🇪🇸 Español',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(localeNotifierProvider.notifier)
                                .setLanguage(AppLanguage.en);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isEs
                                ? AppColors.primaryNavy
                                : Colors.white,
                            foregroundColor: !isEs
                                ? Colors.white
                                : AppColors.primaryNavy,
                            elevation: !isEs ? 2 : 0,
                            side: BorderSide(
                              color: !isEs
                                  ? AppColors.primaryNavy
                                  : const Color(0xFFCBD5E1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '🇺🇸 English',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botón de Cerrar Sesión Institucional
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context, lang),
                icon: const Icon(Icons.logout_rounded,
                    color: Color(0xFFEF4444), size: 18),
                label: Text(
                  Tr.logoutConfirm(lang),
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
  // WIDGETS AUXILIARES
  // =========================================================================
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

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryNavy),
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
              context.go('/login');
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
}
