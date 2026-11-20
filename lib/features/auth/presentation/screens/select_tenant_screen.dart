import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_locale_provider.dart';
import '../../../../core/widgets/bank_brand_logo.dart';
import '../../../../core/widgets/bankos_logo.dart';
import '../../../operations/domain/entities/registered_bank_entity.dart';
import '../../../operations/presentation/providers/operations_providers.dart';
import '../providers/auth_providers.dart';

/// PORTAL CENTRAL DE SELECCIÓN DE ENTIDADES FINANCIERAS (BankOs)
/// - Look & feel limpio, elegante y fusionado con los tonos de BankOs (Figma e Imagen 1 del usuario).
/// - Lista de instituciones bancarias registradas (Bancolombia, Bogotá, Santander, Nu, Occidente).
/// - Acceso directo a "+ Crear Cuenta" e "Iniciar Sesión" en la tarjeta activa.
/// - Apartado dedicado para BankOs Core Global (SuperAdmin) con navegación al Login seguro.
/// - Eliminación del cuadro/selector inferior redundante.
class SelectTenantScreen extends ConsumerStatefulWidget {
  const SelectTenantScreen({super.key});

  @override
  ConsumerState<SelectTenantScreen> createState() => _SelectTenantScreenState();
}

class _SelectTenantScreenState extends ConsumerState<SelectTenantScreen> {
  RegisteredBankEntity? _selectedBank;

  void _loginToSelectedBank(RegisteredBankEntity bank) {
    ref.read(authNotifierProvider.notifier).logout();
    ref.read(operationsNotifierProvider.notifier).switchActiveBank(bank);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    context.go('/login');
  }

  void _navigateToSuperAdminLogin() {
    ref.read(authNotifierProvider.notifier).logout();
    final opsState = ref.read(operationsNotifierProvider);
    final globalBank = opsState.globalBank;
    ref.read(operationsNotifierProvider.notifier).switchActiveBank(globalBank);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(operationsNotifierProvider);
    final lang = ref.watch(localeNotifierProvider);
    final rawBanks = operationsState.banks;

    // Filtrar los bancos comerciales (excluyendo el global para mostrarlo en su apartado dedicado)
    final filteredFromState = rawBanks
        .where((b) => !b.isGlobal && b.id != 'bank_bankos_global')
        .toList();
    final commercialBanks = filteredFromState.isNotEmpty
        ? filteredFromState
        : RegisteredBankEntity.preloadedCommercialBanks;

    RegisteredBankEntity? currentChoice;
    if (commercialBanks.isNotEmpty) {
      if (_selectedBank != null &&
          commercialBanks.any((b) => b.id == _selectedBank!.id)) {
        currentChoice = commercialBanks.firstWhere(
          (b) => b.id == _selectedBank!.id,
        );
      } else if (commercialBanks.any(
        (b) => b.id == operationsState.currentBank.id,
      )) {
        currentChoice = commercialBanks.firstWhere(
          (b) => b.id == operationsState.currentBank.id,
        );
      } else {
        currentChoice = commercialBanks.first;
      }
      _selectedBank = currentChoice;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra Superior con Volver y Logotipo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF0F172A),
                          size: 20,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                      ),
                      const BankOsLogo(
                        iconSize: 26,
                        fontSize: 20,
                        textColor: Color(0xFF0F172A),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Encabezado: "Seleccionar Entidad" (sin banner de entidades)
                  Text(
                    Tr.selectInstitution(lang),
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Tr.selectInstitutionSub(lang),
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // =========================================================
                  // LISTA DE ENTIDADES BANCARIAS COMERCIALES
                  // Al presionar cualquier banco, pasa directamente al login del banco
                  // =========================================================
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: commercialBanks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final bank = commercialBanks[index];
                      final isSelected = currentChoice?.id == bank.id;
                      return _buildEntityCard(
                        bank: bank,
                        isSelected: isSelected,
                        lang: lang,
                        onTap: () => _loginToSelectedBank(bank),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // =========================================================
                  // APARTADO DEDICADO: BANKOS CORE GLOBAL (SUPERADMIN)
                  // =========================================================
                  _buildSuperAdminPortalCard(lang),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Tarjeta de Entidad Bancaria Limpia, Moderna y de Acceso Directo al Login
  Widget _buildEntityCard({
    required RegisteredBankEntity bank,
    required bool isSelected,
    required AppLanguage lang,
    required VoidCallback onTap,
  }) {
    final slug = bank.slug;

    // Colores de acento según la institución
    final Color buttonAccentColor;
    if (slug.contains('lombia')) {
      buttonAccentColor = const Color(0xFFFDDA24);
    } else if (slug.contains('nu')) {
      buttonAccentColor = const Color(0xFF820AD1);
    } else if (slug.contains('santander')) {
      buttonAccentColor = const Color(0xFFEC0000);
    } else if (slug.contains('bogota')) {
      buttonAccentColor = const Color(0xFF004BB1);
    } else {
      buttonAccentColor = bank.primaryColor;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? buttonAccentColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? buttonAccentColor.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        child: Row(
          children: [
            // Contenedor del Emblema / Logo del Banco
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? buttonAccentColor.withValues(alpha: 0.4)
                      : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Center(
                child: BankBrandLogo(bank: bank, size: 24, showName: false),
              ),
            ),
            const SizedBox(width: 14),

            // Nombre del Banco, Badge de Moneda y Subtítulo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          bank.name,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Badge Moneda (USD / COP)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: bank.currency == 'USD'
                              ? const Color(0xFFDCFCE7)
                              : buttonAccentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bank.currency,
                          style: TextStyle(
                            color: bank.currency == 'USD'
                                ? const Color(0xFF16A34A)
                                : (buttonAccentColor == Colors.black
                                      ? const Color(0xFF0F172A)
                                      : buttonAccentColor),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '${Tr.bankCurrencyAccount(lang, bank.currency)} • ',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFF64748B),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        Tr.secureDigitalBanking(lang),
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Apartado Exclusivo para BankOs Core Global (SuperAdmin)
  /// - Conduce directamente al Login Administrativo oficial
  Widget _buildSuperAdminPortalCard(AppLanguage lang) {
    return GestureDetector(
      onTap: _navigateToSuperAdminLogin,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Color(0xFF2563EB),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BankOs Core Global',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    Tr.superAdminConsole(lang),
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _navigateToSuperAdminLogin,
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
              label: Text(
                Tr.superAdminLabel(lang),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
