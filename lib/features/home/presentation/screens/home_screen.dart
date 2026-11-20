import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_locale_provider.dart';
import '../../../../core/widgets/bank_brand_logo.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../operations/domain/entities/registered_bank_entity.dart';
import '../../../operations/domain/entities/operation_record_entity.dart';
import '../../../operations/presentation/providers/operations_providers.dart';
import '../../../operations/presentation/screens/history_screen.dart';
import '../../../operations/presentation/screens/profile_screen.dart';
import '../../../operations/presentation/widgets/transaction_detail_modal.dart';
import '../widgets/notifications_modal.dart';

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
  bool _isBalanceVisible = true;
  final Set<String> _readTransactionIds = {};
  bool _allRead = false;
  final PageController _cardPageController =
      PageController(viewportFraction: 1.0);

  bool get _hasUnreadNotifications {
    if (_allRead) return false;
    final operationsState = ref.watch(operationsNotifierProvider);
    if (operationsState.history.isEmpty) return false;
    return operationsState.history.any((tx) => !_readTransactionIds.contains(tx.id));
  }

  @override
  void dispose() {
    _cardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeNotifierProvider);
    final operationsState = ref.watch(operationsNotifierProvider);
    final currentBank = operationsState.currentBank;
    final activeNavColor = currentBank.primaryColor == Colors.black
        ? const Color(0xFF0F172A)
        : currentBank.primaryColor;

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
                    activeColor: activeNavColor,
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.access_time_rounded,
                    label: Tr.history(lang),
                    activeColor: activeNavColor,
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.person_outline_rounded,
                    label: Tr.profile(lang),
                    activeColor: activeNavColor,
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
    Color activeColor = const Color(0xFF2563EB),
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
                  ? activeColor
                  : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? activeColor
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
    final history = operationsState.activeTenantHistory.take(4).toList();

    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final rawName = user?.name?.trim();
    final String displayName;
    if (rawName != null &&
        rawName.isNotEmpty &&
        rawName != '[Nombre]' &&
        rawName != 'BankOS User' &&
        rawName != 'Usuario BankOS') {
      displayName = rawName;
    } else if (user?.email != null && user!.email.isNotEmpty) {
      final part = user.email.split('@')[0];
      displayName = part.length > 1
          ? (part.substring(0, 1).toUpperCase() + part.substring(1))
          : 'Cliente BankOS';
    } else {
      displayName = 'Cliente BankOS';
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================================================
            // 1. CABECERA SUPERIOR REACTIVA A LA IDENTIDAD DEL BANCO
            // ==============================================================
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.75, 1.0],
                  colors: [
                    currentBank.isGlobal
                        ? const Color(0xFF0F2544)
                        : (currentBank.primaryColor == Colors.black
                            ? const Color(0xFF1E293B)
                            : Color.lerp(currentBank.primaryColor, const Color(0xFF1E3A5F), 0.35)!),
                    currentBank.isGlobal
                        ? const Color(0xFF16325C)
                        : (currentBank.primaryColor == Colors.black
                            ? const Color(0xFF1A2639)
                            : Color.lerp(currentBank.primaryColor, const Color(0xFF162740), 0.50)!),
                    const Color(0xFFF8FAFC),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                                Tr.greeting(lang, displayName),
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
                              setState(() {
                                _allRead = true;
                                _readTransactionIds.addAll(
                                  operationsState.history.map((tx) => tx.id),
                                );
                              });
                              NotificationsModal.show(
                                context: context,
                                lang: lang,
                                history: operationsState.history,
                                currentBank: currentBank,
                              );
                            },
                          ),
                          if (_hasUnreadNotifications)
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

                  // Badge Informativo del Banco Conectado (Sin conmutador modal)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (currentBank.isGlobal
                                ? Colors.white
                                : currentBank.accentColor)
                            .withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        BankBrandLogo(
                          bank: currentBank,
                          size: 22,
                          showName: false,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentBank.isGlobal
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
                                currentBank.isGlobal
                                    ? Tr.globalHub(lang)
                                    : Tr.titularAccount(
                                        lang, currentBank.currency),
                                style: TextStyle(
                                  color: (currentBank.isGlobal
                                          ? const Color(0xFF94A3B8)
                                          : currentBank.accentColor)
                                      .withValues(alpha: 0.95),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                lang == AppLanguage.es ? 'Activo' : 'Active',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tarjeta de Saldo Principal Única (Diseño 3D con Número Real de Cuenta de Base de Datos)
                  _buildFigmaBalanceCard(
                    lang: lang,
                    currentBank: currentBank,
                    balance: operationsState.formattedActiveBalance,
                    accountNumber: operationsState.primaryAccount?.accountNumber ??
                        operationsState.primaryCard?.cardNumber ??
                        '8008008001',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ==============================================================
            // 2. SECCIÓN: OPERACIONES FINANCIERAS (DEPÓSITO, TRANSFERENCIA Y RETIRO)
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
                      icon: Icons.swap_horiz_rounded,
                      label: lang == AppLanguage.es ? 'Transferir' : 'Transfer',
                      bgColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      iconColor: const Color(0xFF2563EB),
                      onTap: () => context.go('/transfer'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFigmaActionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: lang == AppLanguage.es ? 'Depositar' : 'Deposit',
                      bgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                      iconColor: const Color(0xFF10B981),
                      onTap: () => context.go('/deposit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFigmaActionButton(
                      icon: Icons.remove_circle_outline_rounded,
                      label: Tr.withdraw(lang),
                      bgColor: currentBank.accentColor.withValues(alpha: 0.15),
                      iconColor: currentBank.primaryColor == Colors.black
                          ? const Color(0xFF0F172A)
                          : currentBank.primaryColor,
                      onTap: () => context.go('/withdraw'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

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

  /// Chip EMV Metálico Dorado 3D (Microprocesador de tarjeta física real con relieve y brillo)
  Widget _buildEmvChip() {
    return Container(
      width: 32,
      height: 24,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF9C4),
            Color(0xFFFDD835),
            Color(0xFFF59E0B),
            Color(0xFFD97706),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFFBBF24), width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 3,
            offset: const Offset(1, 1.5),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.35),
            blurRadius: 1,
            offset: const Offset(-0.5, -0.5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Líneas divisorias de circuitos del microprocesador
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: const Color(0xFF92400E).withValues(alpha: 0.45)),
          ),
          Positioned(
            left: 21,
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: const Color(0xFF92400E).withValues(alpha: 0.45)),
          ),
          Positioned(
            top: 11,
            left: 0,
            right: 0,
            child: Container(height: 1, color: const Color(0xFF92400E).withValues(alpha: 0.45)),
          ),
          // Núcleo central del chip
          Center(
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFFB45309).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: const Color(0xFF92400E).withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de Saldo Física 3D (Perspectiva 3D, Iluminación Especular, Chip Dorado y Relieve)
  Widget _buildFigmaBalanceCard({
    required AppLanguage lang,
    required RegisteredBankEntity currentBank,
    required String balance,
    required String accountNumber,
  }) {
    final slug = currentBank.slug;
    final List<Color> gradientColors;
    if (slug.contains('nu')) {
      gradientColors = [const Color(0xFF820AD1), const Color(0xFF4C0677), const Color(0xFF280242)];
    } else if (slug.contains('lombia')) {
      gradientColors = [const Color(0xFF1E293B), const Color(0xFF0F172A), const Color(0xFF020617)];
    } else if (slug.contains('santander')) {
      gradientColors = [const Color(0xFFEF4444), const Color(0xFFDC2626), const Color(0xFF7F1D1D)];
    } else if (slug.contains('bogota')) {
      gradientColors = [const Color(0xFF003B95), const Color(0xFF002D72), const Color(0xFF00173D)];
    } else if (slug.contains('occidente')) {
      gradientColors = [const Color(0xFF0052FF), const Color(0xFF0A2540), const Color(0xFF051424)];
    } else if (currentBank.isGlobal) {
      gradientColors = [const Color(0xFF0A2558), const Color(0xFF031633), const Color(0xFF020A17)];
    } else {
      gradientColors = [
        currentBank.primaryColor,
        currentBank.primaryColor.withValues(alpha: 0.85),
        const Color(0xFF020617),
      ];
    }

    final accentGlow = currentBank.isGlobal
        ? const Color(0xFF0052FF)
        : (currentBank.primaryColor == Colors.black
            ? currentBank.accentColor
            : currentBank.primaryColor);

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0008) // Perspectiva 3D
        ..rotateX(0.035)          // Inclinación 3D hacia atrás
        ..rotateY(-0.015),        // Ángulo dimensional sutil
      alignment: FractionalOffset.center,
      child: Container(
        height: 195,
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 1.4,
          ),
          boxShadow: [
            // Sombra profunda de suspensión física 3D
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 18),
            ),
            // Resplandor reactivo de iluminación ambiental según el banco
            BoxShadow(
              color: accentGlow.withValues(alpha: 0.42),
              blurRadius: 32,
              spreadRadius: -2,
              offset: const Offset(0, 10),
            ),
            // Bisel superior iluminado (Rim Light)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.16),
              blurRadius: 4,
              offset: const Offset(0, -1.5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Reflejo Especular Diagonal 3D (Efecto brillo cristalizado)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.28),
                        Colors.white.withValues(alpha: 0.06),
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.04),
                        Colors.white.withValues(alpha: 0.12),
                      ],
                      stops: const [0.0, 0.28, 0.55, 0.82, 1.0],
                    ),
                  ),
                ),
              ),

              // Círculos holográficos concéntricos de fondo en 3D
              Positioned(
                right: -25,
                bottom: -35,
                child: Container(
                  width: 175,
                  height: 175,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (currentBank.isGlobal ? Colors.white : currentBank.accentColor)
                        .withValues(alpha: 0.14),
                  ),
                ),
              ),
              Positioned(
                right: 35,
                bottom: -50,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Fila Superior: Emblema + Nombre del Banco + Chip 3D + Contactless
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: BankBrandLogo(
                                bank: currentBank,
                                size: 20,
                                showName: false,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              currentBank.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildEmvChip(),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.contactless_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Fila Central: Dinero actual + Saldo grande con relieve y sombra
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Tr.availableBalance(lang),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isBalanceVisible = !_isBalanceVisible;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isBalanceVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: Text(
                              _isBalanceVisible ? balance : '••••••••',
                              key: ValueKey<bool>(_isBalanceVisible),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Fila Inferior: Número de Tarjeta en Relieve + Badge de Moneda
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${Tr.savingsAccount(lang)} $accountNumber',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
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
                                size: 13,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 0.9,
                            ),
                          ),
                          child: Text(
                            currentBank.currency,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
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
      ),
    );
  }

  /// Botón de Acción Rápida (Figma)
  Widget _buildFigmaActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? bgColor,
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
              color: bgColor ?? const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFF2563EB),
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
    final isIncoming = item is OperationRecordEntity && item.isIncoming;
    final isCredit = isDeposit || isIncoming;

    final Color iconBg = isCredit
        ? const Color(0xFFDCFCE7)
        : (isExchange ? const Color(0xFFFAF5FF) : const Color(0xFFFEE2E2));
    final Color iconColor = isCredit
        ? const Color(0xFF16A34A)
        : (isExchange ? const Color(0xFF7C3AED) : const Color(0xFFDC2626));
    final IconData icon = isCredit
        ? Icons.arrow_downward_rounded
        : (isExchange
            ? Icons.currency_exchange_rounded
            : Icons.arrow_upward_rounded);

    final Color amountColor =
        isCredit ? const Color(0xFF16A34A) : const Color(0xFF0F172A);

    return InkWell(
      onTap: () {
        if (item is OperationRecordEntity) {
          TransactionDetailModal.show(context, item, lang);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
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
                  item.formattedAmount,
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
      ),
    );
  }
}
