import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bank_brand_logo.dart';
import '../../../../core/widgets/bankos_logo.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_providers.dart';
import '../../../operations/domain/entities/registered_bank_entity.dart';
import '../../../operations/presentation/providers/operations_providers.dart';

/// PORTAL CENTRAL DE SELECCIÓN DE BANCOS & ACCESO AISLADO
/// - Muestra los bancos comerciales creados (Nu, Bancolombia, Bogotá, Santander).
/// - Permite entrar con credenciales existentes o crear una cuenta nueva en ese banco.
/// - Apartado exclusivo de BankOs Core para inicio de sesión de SuperAdmin.
/// - Diseños 3D de tarjetas con iluminación, chips y micro-interacciones suaves.
class SelectTenantScreen extends ConsumerStatefulWidget {
  const SelectTenantScreen({super.key});

  @override
  ConsumerState<SelectTenantScreen> createState() => _SelectTenantScreenState();
}

class _SelectTenantScreenState extends ConsumerState<SelectTenantScreen> {
  RegisteredBankEntity? _selectedBank;

  void _confirmSelection() {
    final operationsState = ref.read(operationsNotifierProvider);
    final bank = _selectedBank ??
        (operationsState.banks.isNotEmpty ? operationsState.banks.first : null);

    if (bank != null) {
      ref.read(operationsNotifierProvider.notifier).switchActiveBank(bank);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      context.go('/login');
    }
  }

  void _loginToSelectedBank(RegisteredBankEntity bank) {
    ref.read(operationsNotifierProvider.notifier).switchActiveBank(bank);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    context.go('/login');
  }

  void _loginAsSuperAdmin() async {
    final opsState = ref.read(operationsNotifierProvider);
    final globalBank = opsState.globalBank;
    ref.read(operationsNotifierProvider.notifier).switchActiveBank(globalBank);
    await ref.read(authNotifierProvider.notifier).login(
      'admin@bankos.com',
      '1234',
      role: UserRole.admin,
    );
    if (mounted) {
      context.go('/admin');
    }
  }

  void _registerInSelectedBank(RegisteredBankEntity bank) {
    ref.read(operationsNotifierProvider.notifier).switchActiveBank(bank);
    context.go('/register');
  }

  void _quickClientLogin(RegisteredBankEntity bank) async {
    ref.read(operationsNotifierProvider.notifier).switchActiveBank(bank);
    final email = 'cliente@${bank.code.toLowerCase()}.com';
    await ref.read(authNotifierProvider.notifier).login(
      email,
      '1234',
      role: UserRole.client,
    );
    if (mounted) {
      context.go('/home');
    }
  }

  void _quickAdminLogin(RegisteredBankEntity bank) async {
    ref.read(operationsNotifierProvider.notifier).switchActiveBank(bank);
    final email = 'admin@${bank.code.toLowerCase()}.com';
    await ref.read(authNotifierProvider.notifier).login(
      email,
      '1234',
      role: UserRole.admin,
    );
    if (mounted) {
      context.go('/admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(operationsNotifierProvider);
    final banks = operationsState.banks;

    RegisteredBankEntity? currentChoice;
    if (banks.isNotEmpty) {
      if (_selectedBank != null && banks.any((b) => b.id == _selectedBank!.id)) {
        currentChoice = banks.firstWhere((b) => b.id == _selectedBank!.id);
      } else if (banks.any((b) => b.id == operationsState.currentBank.id)) {
        currentChoice = banks.firstWhere((b) => b.id == operationsState.currentBank.id);
      } else {
        currentChoice = banks.first;
      }
      _selectedBank = currentChoice;
    }

    // Filtrar los bancos comerciales (excluyendo el global de BankOs para mostrarlo en su apartado dedicado)
    final commercialBanks =
        banks.where((b) => !b.isGlobal && b.id != 'bank_bankos_global').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Barra Superior con Volver y Logotipo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: AppColors.primaryNavy, size: 20),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/onboarding');
                          }
                        },
                      ),
                      const BankOsLogo(
                        iconSize: 26,
                        fontSize: 20,
                        textColor: AppColors.primaryNavy,
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Título Principal
                  const Text(
                    'Elige tu Entidad Financiera',
                    style: TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Selecciona el banco para entrar o crear una cuenta:',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // =========================================================
                  // CUADRÍCULA / LISTA DE TARJETAS 3D DE BANCOS COMERCIALES
                  // =========================================================
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: commercialBanks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final bank = commercialBanks[index];
                      final isSelected = currentChoice?.id == bank.id;
                      return _build3DBankCard(
                        bank: bank,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedBank = bank);
                          ref.read(operationsNotifierProvider.notifier).switchActiveBank(bank);
                        },
                        onLogin: () => _loginToSelectedBank(bank),
                        onRegister: () => _registerInSelectedBank(bank),
                        onQuickClient: () => _quickClientLogin(bank),
                        onQuickAdmin: () => _quickAdminLogin(bank),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // =========================================================
                  // APARTADO DEDICADO: BANKOS CORE (SUPERADMIN)
                  // =========================================================
                  _buildSuperAdminPortalCard(),

                  const SizedBox(height: 18),

                  // Selector Desplegable Sincronizado (Compatibilidad Widget Tests)
                  Row(
                    children: [
                      const Text(
                        'Banco / Tenant a ingresar:',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<RegisteredBankEntity>(
                              value: currentChoice,
                              isDense: true,
                              isExpanded: true,
                              items: banks.map((b) {
                                return DropdownMenuItem(
                                  value: b,
                                  child: Text(
                                    b.name,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (b) {
                                if (b != null) setState(() => _selectedBank = b);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Botón Principal de Confirmación (Tocado en Widget Tests)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentChoice?.primaryColor == Colors.black
                            ? const Color(0xFF0F172A)
                            : (currentChoice?.primaryColor ?? AppColors.primaryNavy),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: (currentChoice?.accentColor ?? Colors.transparent)
                                .withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              currentChoice != null
                                  ? 'Ingresar a ${currentChoice.name}'
                                  : 'Ingresar a este banco',
                              style: TextStyle(
                                color: (currentChoice != null &&
                                        currentChoice.primaryColor == Colors.black)
                                    ? currentChoice.accentColor
                                    : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: (currentChoice != null &&
                                    currentChoice.primaryColor == Colors.black)
                                ? currentChoice.accentColor
                                : Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Tarjeta 3D interactiva para cada banco comercial
  Widget _build3DBankCard({
    required RegisteredBankEntity bank,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onLogin,
    required VoidCallback onRegister,
    required VoidCallback onQuickClient,
    required VoidCallback onQuickAdmin,
  }) {
    final slug = bank.code.toLowerCase();
    final List<Color> gradientColors;
    if (slug.contains('nu')) {
      gradientColors = [const Color(0xFF820AD1), const Color(0xFF5B0794)];
    } else if (slug.contains('lombia')) {
      gradientColors = [const Color(0xFF0F172A), const Color(0xFF1E293B)];
    } else if (slug.contains('santander')) {
      gradientColors = [const Color(0xFFEC0000), const Color(0xFF990000)];
    } else if (slug.contains('bogota')) {
      gradientColors = [const Color(0xFF002D72), const Color(0xFF001944)];
    } else {
      gradientColors = [bank.primaryColor, bank.primaryColor.withValues(alpha: 0.85)];
    }

    final accentColor = bank.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 2.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? gradientColors[0].withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: isSelected ? 14 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Brillo diagonal 3D sutil
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: BankBrandLogo(bank: bank, size: 22, showName: false),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bank.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Cuenta en ${bank.currency} • Entidad Aislada',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Indicador de selección
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.2),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: accentColor == Colors.white ? Colors.black : Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ],
                    ),

                    if (isSelected) ...[
                      const SizedBox(height: 14),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onRegister,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white70),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text(
                                '+ Crear Cuenta',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: accentColor == Colors.white
                                    ? Colors.black
                                    : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Apartado Exclusivo para BankOs Core (SuperAdmin)
  Widget _buildSuperAdminPortalCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF031633), Color(0xFF08214D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0052FF).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052FF).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0052FF).withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0052FF), width: 1.5),
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BankOs Core Global',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Consola para Administrador General',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _loginAsSuperAdmin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052FF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'SuperAdmin',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
