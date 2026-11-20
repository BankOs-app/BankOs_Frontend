import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../providers/operations_providers.dart';
import '../providers/operations_state.dart';
import '../widgets/transaction_pin_modal.dart';

class DepositScreen extends ConsumerStatefulWidget {
  const DepositScreen({super.key});

  @override
  ConsumerState<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends ConsumerState<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();

  BankCardEntity? _sessionAccountCard(
    OperationsState state,
    String? customerName,
  ) {
    final bank = state.currentBank;
    if (customerName == null || customerName.trim().isEmpty) return null;

    final ownedCard = state
        .getCardsForBank(bank.id)
        .where(
          (card) =>
              card.cardHolder.trim().toLowerCase() ==
              customerName.trim().toLowerCase(),
        )
        .firstOrNull;
    if (ownedCard != null) return ownedCard;

    final account = state.activeTenantAccounts.firstOrNull;
    if (account == null) return null;
    return BankCardEntity(
      id: account.id,
      bankId: bank.id,
      bankName: bank.name,
      cardNumber: account.accountNumber,
      cardHolder: customerName,
      cardType: BankCardType.debit,
      availableBalance: account.balance,
      currency: account.currency,
      isActive: account.isActive,
      accountId: account.id,
    );
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
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

  Future<void> _submitDeposit() async {
    final lang = ref.read(localeNotifierProvider);
    final session = ref.read(operationsNotifierProvider);
    final bank = session.currentBank;
    final customerName = ref.read(authNotifierProvider).user?.name;
    final card = _sessionAccountCard(session, customerName);
    if (card == null) {
      _showSnackBar(Tr.withdrawNoAccount(lang));
      return;
    }

    if (!card.isActive) {
      _showSnackBar(Tr.withdrawInactiveAccount(lang));
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar(
        lang == AppLanguage.es
            ? 'Ingresa un monto válido para depositar.'
            : 'Enter a valid amount to deposit.',
      );
      return;
    }

    final brandAccent = bank.accentColor;
    final authorized = await TransactionPinModal.show(
      context,
      title: lang == AppLanguage.es
          ? 'Autorizar Depósito (${bank.name})'
          : 'Authorize Deposit (${bank.name})',
      amountFormatted: '${card.currency} \$${amount.toStringAsFixed(2)}',
      accentColor: brandAccent,
    );
    if (!authorized || !mounted) return;

    final success = await ref
        .read(operationsNotifierProvider.notifier)
        .executeDepositToCard(
          bank: bank,
          card: card,
          amount: amount,
          concept: _conceptController.text.trim().isNotEmpty
              ? _conceptController.text.trim()
              : (lang == AppLanguage.es
                  ? 'Depósito en efectivo'
                  : 'Cash deposit'),
        );

    if (mounted) {
      final state = ref.read(operationsNotifierProvider);
      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
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
                  lang == AppLanguage.es
                      ? '¡Depósito exitoso!'
                      : 'Deposit successful!',
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(
              lang == AppLanguage.es
                  ? 'Se han depositado \$${amount.toStringAsFixed(2)} ${card.currency} exitosamente en tu cuenta de ${bank.name}.'
                  : '\$${amount.toStringAsFixed(2)} ${card.currency} was successfully deposited into your ${bank.name} account.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(Tr.accept(lang)),
              ),
            ],
          ),
        );
        _amountController.clear();
        _conceptController.clear();
      } else {
        _showSnackBar(state.errorMessage ?? Tr.genericError(lang));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeNotifierProvider);
    final operationsState = ref.watch(operationsNotifierProvider);
    final customerName = ref.watch(authNotifierProvider).user?.name;
    final bank = operationsState.currentBank;
    final card = _sessionAccountCard(operationsState, customerName);
    final depositCurrency = card?.currency ?? bank.currency;
    final isLoading = operationsState.status == OperationsStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryNavy,
            size: 20,
          ),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          lang == AppLanguage.es ? 'Depósito de fondos' : 'Deposit funds',
          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. BANCO REGISTRADO
                  Text(
                    lang == AppLanguage.es
                        ? '1. Banco registrado:'
                        : '1. Registered bank:',
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _accountSummary('', '${bank.name} (${bank.currency})'),

                  const SizedBox(height: 18),

                  // 2. CUENTA DESTINO POR DEFAULT (CUENTA DE LA SESIÓN)
                  Text(
                    lang == AppLanguage.es
                        ? '2. Cuenta a acreditar (donde se recibirán los fondos):'
                        : '2. Destination account (where funds will be received):',
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _accountSummary(
                    '',
                    card == null
                        ? Tr.withdrawNoAccount(lang)
                        : '${bank.name} • ${Tr.cardType(lang, card.cardType == BankCardType.credit)} • No. ${card.cardNumber} (${card.formattedBalance})',
                  ),

                  const SizedBox(height: 18),

                  // 3. MONTO A DEPOSITAR
                  Text(
                    lang == AppLanguage.es
                        ? '3. Monto a depositar:'
                        : '3. Amount to deposit:',
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.softBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          depositCurrency == 'EUR'
                              ? Icons.euro_rounded
                              : Icons.attach_money_rounded,
                          color: const Color(0xFF10B981),
                          size: 20,
                        ),
                        suffixText: depositCurrency,
                        suffixStyle: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        hintText: '0.00',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Concepto (Opcional)
                  Text(
                    Tr.conceptOptional(lang),
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.softBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _conceptController,
                      style: const TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: lang == AppLanguage.es
                            ? 'Ej. Depósito en efectivo o consignación'
                            : 'e.g. Cash deposit or payroll',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Botón de Confirmación
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitDeposit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              lang == AppLanguage.es
                                  ? 'Continuar y depositar'
                                  : 'Continue and deposit',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _accountSummary(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.primaryNavy,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
