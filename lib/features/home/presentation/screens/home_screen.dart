import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_locale_provider.dart';
import '../../../operations/domain/entities/external_origin_account_entity.dart';
import '../../../operations/domain/entities/registered_bank_entity.dart';
import '../../../operations/presentation/providers/operations_providers.dart';
import '../../../operations/presentation/providers/operations_state.dart';
import '../../../operations/presentation/screens/history_screen.dart';
import '../../../operations/presentation/screens/profile_screen.dart';

/// PERFIL CLIENTE (BankOs):
/// - Consultar y operar sobre las cuentas de las cuales es titular.
/// - Diseño responsive para iPad y Móvil (adaptable y sin bordes muertos).
/// - 3 Pestañas en navegación: Inicio, Historial, Perfil (sin transferencias internas).
/// - Bilingüe (Español / Inglés) reactivo con Tr.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentNavIndex = 0;
  int _currentCardIndex = 0;
  bool _isBalanceVisible = true;
  final PageController _cardPageController =
      PageController(viewportFraction: 1.0);

  @override
  void dispose() {
    _cardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: IndexedStack(
            index: _currentNavIndex,
            children: [
              // Tab 0: Inicio (Dashboard de Cuentas del Titular - Figma exacto)
              _buildClientDashboardView(lang),

              // Tab 1: Historial de Operaciones
              const HistoryScreen(),

              // Tab 2: Perfil del Cliente
              const ProfileScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_rounded,
                    label: Tr.home(lang),
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.access_time_rounded,
                    label: Tr.history(lang),
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.person_outline_rounded,
                    label: Tr.profile(lang),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // VISTA TAB 0: DASHBOARD DE CLIENTE (FIGMA EXACTO & RESPONSIVE IPAD)
  // =========================================================================
  Widget _buildClientDashboardView(AppLanguage lang) {
    final operationsState = ref.watch(operationsNotifierProvider);
    final currentBank = operationsState.currentBank;
    final activeCards = operationsState.activeTenantCards;
    final activeAccounts = operationsState.activeTenantAccounts;
    final history = operationsState.activeTenantHistory.take(4).toList();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================================================
            // 1. CABECERA SUPERIOR AZUL MARINO (#031F48) - Figma Mockup
            // ==============================================================
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF031633),
                    Color(0xFF0A2558),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila 1: Saludo, Avatar y Notificaciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _currentNavIndex = 2),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Tr.greeting(lang, '[Nombre]'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                Tr.welcome(lang),
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Campana de Notificaciones con Badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    lang == AppLanguage.es
                                        ? 'No tienes notificaciones pendientes.'
                                        : 'You have no pending notifications.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Chip Selector de Banco / Institución Activa
                  GestureDetector(
                    onTap: () => _showAccountSwitcherDialog(context, lang),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            operationsState.isViewingGlobal
                                ? Icons.public_rounded
                                : Icons.account_balance_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  operationsState.isViewingGlobal
                                      ? 'BankOs Global (USD)'
                                      : '${currentBank.name} (${currentBank.currency})',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  operationsState.isViewingGlobal
                                      ? Tr.globalHub(lang)
                                      : Tr.titularAccount(
                                          lang, currentBank.currency),
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showAccountSwitcherDialog(context, lang),
                            icon:
                                const Icon(Icons.swap_horiz_rounded, size: 14),
                            label: Text(
                              Tr.change(lang),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.18),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tarjeta de Saldo Principal (Figma Navy Card con detalle geométrico)
                  SizedBox(
                    height: 155,
                    child: PageView(
                      controller: _cardPageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentCardIndex = index;
                        });
                      },
                      children: [
                        _buildFigmaBalanceCard(
                          lang: lang,
                          balance: operationsState.formattedActiveBalance,
                          accountNumber: operationsState
                                  .primaryCard?.maskedCardNumber ??
                              operationsState
                                  .primaryAccount?.maskedAccountNumber ??
                              '•••• 4821',
                        ),
                        if (activeCards.length > 1)
                          _buildFigmaBalanceCard(
                            lang: lang,
                            balance: activeCards[1].formattedBalance,
                            accountNumber: activeCards[1].maskedCardNumber,
                          )
                        else if (activeAccounts.length > 1)
                          _buildFigmaBalanceCard(
                            lang: lang,
                            balance: activeAccounts[1].formattedBalance,
                            accountNumber: activeAccounts[1].maskedAccountNumber,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Indicador de Puntos Centrado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3.0),
                        width: index == _currentCardIndex ? 16.0 : 6.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: index == _currentCardIndex
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==============================================================
            // 2. SECCIÓN: OPERACIONES FINANCIERAS (3 BOTONES LIMPIOS)
            // ==============================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Text(
                Tr.financialOps(lang),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
              child: Row(
                children: [
                  Expanded(
                    child: _buildFigmaActionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: Tr.deposit(lang),
                      onTap: () => context.go('/deposit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFigmaActionButton(
                      icon: Icons.remove_circle_outline_rounded,
                      label: Tr.withdraw(lang),
                      onTap: () => context.go('/withdraw'),
                    ),
                  ),
                ],
              ),
            ),

            // ==============================================================
            // 3. SECCIÓN: TRANSACCIONES HECHAS / MOVIMIENTOS RECIENTES
            // ==============================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      Tr.recentTransactions(lang),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentNavIndex = 1),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      Tr.viewAll(lang),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de Transacciones Limpia
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      Tr.noTransactions(lang),
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Color(0xFFF1F5F9),
                    height: 1,
                    indent: 60,
                  ),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _buildFigmaTransactionTile(item, lang);
                  },
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // SUBCOMPONENTES FIGMA
  // =========================================================================

  /// Tarjeta de Saldo Figma (Fondo Azul Noche con forma curva en la esquina)
  Widget _buildFigmaBalanceCard({
    required AppLanguage lang,
    required String balance,
    required String accountNumber,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2C59),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Círculo translúcido curva inferior derecha (Figma)
            Positioned(
              right: -30,
              bottom: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0284C7).withValues(alpha: 0.22),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Tr.availableBalance(lang),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isBalanceVisible = !_isBalanceVisible;
                          });
                        },
                        child: Icon(
                          _isBalanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isBalanceVisible ? balance : '••••••••',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${Tr.savingsAccount(lang)} $accountNumber',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: accountNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(lang == AppLanguage.es
                                  ? 'Número de cuenta copiado.'
                                  : 'Account number copied.'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy_rounded,
                          color: Colors.white70,
                          size: 14,
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

  /// Botón de Acción Rápida (Figma)
  Widget _buildFigmaActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Item de Transacción (Figma)
  Widget _buildFigmaTransactionTile(dynamic item, AppLanguage lang) {
    final typeStr = item.type.toString();
    final isDeposit = typeStr.contains('deposit');
    final isExchange = typeStr.contains('currencyExchange');

    final Color iconBg = isDeposit
        ? const Color(0xFFDCFCE7)
        : (isExchange ? const Color(0xFFFAF5FF) : const Color(0xFFFEE2E2));
    final Color iconColor = isDeposit
        ? const Color(0xFF16A34A)
        : (isExchange ? const Color(0xFF7C3AED) : const Color(0xFFDC2626));
    final IconData icon = isDeposit
        ? Icons.arrow_downward_rounded
        : (isExchange
            ? Icons.currency_exchange_rounded
            : Icons.arrow_upward_rounded);

    final String amountPrefix = isDeposit ? '+ ' : '- ';
    final Color amountColor =
        isDeposit ? const Color(0xFF16A34A) : const Color(0xFF0F172A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix${item.formattedAmount}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                lang == AppLanguage.es ? 'Hoy, reciente' : 'Today, recent',
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
  }

  // =========================================================================
  // SELECTOR DE CUENTAS DEL TITULAR (RESPONSIVE IPAD & MODAL BONITO)
  // =========================================================================
  String _getBankBalanceDisplay(
      RegisteredBankEntity bank, OperationsState state) {
    final bankCards = state.getCardsForBank(bank.id);
    if (bankCards.isNotEmpty) {
      return bankCards.first.formattedBalance;
    }
    final orig = state.originAccounts.firstWhere(
      (o) =>
          o.bankName.toLowerCase().trim() == bank.name.toLowerCase().trim() ||
          bank.name.toLowerCase().contains(o.bankName.toLowerCase()) ||
          o.bankName.toLowerCase().contains(bank.name.toLowerCase()),
      orElse: () => ExternalOriginAccountEntity(
        id: '',
        bankName: bank.name,
        accountType: 'Cuenta Débito',
        accountNumber: '0000',
        holderName: 'Carlos Gómez',
        currency: bank.currency,
        balance: 0.0,
      ),
    );
    return orig.formattedBalance;
  }

  void _showAccountSwitcherDialog(BuildContext context, AppLanguage lang) {
    final operationsState = ref.read(operationsNotifierProvider);
    final currentBank = operationsState.currentBank;
    final globalBank = operationsState.globalBank;
    final personalBanks = operationsState.personalBanks;
    final isEs = lang == AppLanguage.es;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22.0, vertical: 18.0),
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
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            color: Color(0xFF2563EB), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            Tr.myTitularAccounts(lang),
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFF64748B), size: 22),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEs
                          ? 'Cuentas registradas de las cuales eres titular legal. Alterna para operar en cada entidad financiera aislada.'
                          : 'Registered accounts of which you are the legal titular. Switch to operate in each isolated financial entity.',
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 18),

                    // 1. CUENTA GLOBAL BANKOS (HUB CENTRAL)
                    Text(
                      Tr.globalAccountTitle(lang),
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Builder(
                      builder: (context) {
                        final isGlobalActive = currentBank.id == globalBank.id;
                        final bal =
                            _getBankBalanceDisplay(globalBank, operationsState);
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isGlobalActive
                                ? const Color(0xFFF1F5F9)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isGlobalActive
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE2E8F0),
                              width: isGlobalActive ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0284C7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.public_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
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
                                            globalBank.name,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0284C7),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'GLOBAL • USD',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${isEs ? "Saldo" : "Balance"}: $bal',
                                      style: const TextStyle(
                                        color: Color(0xFF2563EB),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isGlobalActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isEs ? 'Activa' : 'Active',
                                    style: const TextStyle(
                                      color: Color(0xFF059669),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(operationsNotifierProvider
                                            .notifier)
                                        .switchActiveBank(globalBank);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEs
                                              ? 'Has ingresado a tu Cuenta Global BankOs (USD).'
                                              : 'You have switched to your BankOs Global Account (USD).',
                                        ),
                                        backgroundColor:
                                            const Color(0xFF2563EB),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    isEs ? 'Ingresar' : 'Switch',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // 2. CUENTAS PERSONALES REGISTRADAS DE OTROS BANCOS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Tr.otherBanks(lang),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '(${personalBanks.length})',
                          style: const TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: personalBanks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final bank = personalBanks[index];
                        final isActive = bank.id == currentBank.id;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFF1F5F9)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFE2E8F0),
                              width: isActive ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: bank.currency == 'USD'
                                      ? const Color(0xFF1E3A8A)
                                      : const Color(0xFF065F46),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.account_balance_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            bank.name,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            bank.currency,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${isEs ? "Saldo" : "Balance"}: ${_getBankBalanceDisplay(bank, operationsState)}',
                                      style: TextStyle(
                                        color: isActive
                                            ? const Color(0xFF059669)
                                            : const Color(0xFF64748B),
                                        fontSize: 12,
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isEs ? 'Activo' : 'Active',
                                    style: const TextStyle(
                                      color: Color(0xFF059669),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(operationsNotifierProvider
                                            .notifier)
                                        .switchActiveBank(bank);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEs
                                              ? 'Sesión cambiada a ${bank.name}. Has ingresado a tu cuenta en ${bank.currency}.'
                                              : 'Switched session to ${bank.name} (${bank.currency}).',
                                        ),
                                        backgroundColor:
                                            const Color(0xFF2563EB),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    isEs ? 'Ingresar' : 'Switch',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
