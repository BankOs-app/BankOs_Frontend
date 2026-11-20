import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/static_exchange_rate.dart';
import '../providers/operations_providers.dart';
import '../providers/operations_state.dart';
import '../widgets/multi_currency_conversion_card.dart';
import '../widgets/transaction_pin_modal.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();

  String? _withdrawCurrency;
  String? _currencyBankId;
  String? _currencyCardId;

  BankCardEntity? _sessionAccountCard(
    OperationsState state,
    String? customerName,
  ) {
    final bank = state.currentBank;
    if (customerName != null && customerName.trim().isNotEmpty) {
      final ownedCard = state
          .getCardsForBank(bank.id)
          .where(
            (card) =>
                card.cardHolder.trim().toLowerCase() ==
                customerName.trim().toLowerCase(),
          )
          .firstOrNull;
      if (ownedCard != null) return ownedCard;
    }

    final activeCard = state.activeTenantCards.firstOrNull;
    if (activeCard != null) return activeCard;

    final account =
        state.activeTenantAccounts.firstOrNull ?? state.primaryAccount;
    if (account != null) {
      return BankCardEntity(
        id: account.id,
        bankId: bank.id,
        bankName: bank.name,
        cardNumber: account.accountNumber,
        cardHolder: customerName ?? 'Cliente BankOS',
        cardType: BankCardType.debit,
        availableBalance: account.balance,
        currency: account.currency,
        isActive: account.isActive,
        accountId: account.id,
      );
    }

    return state.primaryCard;
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
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submitWithdrawal() async {
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
    if (amount == null) {
      _showSnackBar(Tr.withdrawInvalidAmount(lang));
      return;
    }

    if (amount <= 0) {
      _showSnackBar(Tr.withdrawPositiveAmount(lang));
      return;
    }

    final withdrawCurr = _withdrawCurrency ?? card.currency;

    double requiredDebit = amount;
    if (withdrawCurr != card.currency) {
      final rate = StaticExchangeRate.getRate(withdrawCurr, card.currency);
      requiredDebit = amount * rate;
    }

    if (requiredDebit > card.availableBalance) {
      _showSnackBar(
        Tr.withdrawInsufficientFunds(
          lang,
          card.formattedBalance,
          '\$${requiredDebit.toStringAsFixed(2)}',
          '\$${amount.toStringAsFixed(2)}',
          card.currency,
          withdrawCurr,
        ),
      );
      return;
    }

    final brandAccent = bank.accentColor;
    final authorized = await TransactionPinModal.show(
      context,
      title: Tr.withdrawPinTitle(lang, bank.name),
      amountFormatted: '$withdrawCurr $amountText',
      accentColor: brandAccent,
    );
    if (!authorized || !mounted) return;

    final success = await ref
        .read(operationsNotifierProvider.notifier)
        .executeWithdrawFromCard(
          bank: bank,
          card: card,
          amount: amount,
          withdrawCurrency: withdrawCurr,
          concept: _conceptController.text.trim().isNotEmpty
              ? _conceptController.text.trim()
              : Tr.withdrawDefaultConcept(
                  lang,
                  withdrawCurr,
                  Tr.cardType(lang, card.cardType == BankCardType.credit),
                ),
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
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  Tr.withdrawSuccessTitle(lang),
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(
              Tr.withdrawSuccessMessage(
                lang,
                '\$${amount.toStringAsFixed(2)}',
                withdrawCurr,
                bank.name,
              ),
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
    if (_currencyBankId != bank.id || _currencyCardId != card?.id) {
      _currencyBankId = bank.id;
      _currencyCardId = card?.id;
      _withdrawCurrency = card?.currency ?? bank.currency;
    }
    _withdrawCurrency ??= card?.currency ?? bank.currency;

    final effectiveWithdrawCurrency = _withdrawCurrency!;

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
          Tr.withdrawFunds(lang),
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
                    Tr.withdrawBankLabel(lang),
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  _accountSummary('', '${bank.name} (${bank.currency})'),

                  const SizedBox(height: 18),

                  // 2. CUENTA DEBITADA DE LA SESIÓN ACTIVA
                  Text(
                    Tr.withdrawAccountLabel(lang),
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
                        : '${Tr.cardType(lang, card.cardType == BankCardType.credit)} · ${card.displayAccountNumber} · ${card.formattedBalance}',
                  ),

                  const SizedBox(height: 18),

                  // 3. MONTO A RETIRAR
                  Text(
                    Tr.withdrawAmount(lang),
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
                          _withdrawCurrency == 'EUR'
                              ? Icons.euro_rounded
                              : Icons.attach_money_rounded,
                          color: AppColors.brandBlue,
                          size: 20,
                        ),
                        suffixText: _withdrawCurrency,
                        suffixStyle: const TextStyle(
                          color: AppColors.brandBlue,
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

                  const SizedBox(height: 14),

                  // Concepto (Opcional)
                  Text(
                    Tr.conceptOptional(lang),
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: Tr.withdrawConceptHint(lang),
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  // Tablero de Conversión en Tiempo Real (solo si difieren divisas)
                  MultiCurrencyConversionCard(
                    originCurrency: card?.currency ?? bank.currency,
                    destinationCurrency: effectiveWithdrawCurrency,
                    amount:
                        double.tryParse(_amountController.text.trim()) ?? 0.0,
                    isWithdrawal: true,
                  ),

                  const SizedBox(height: 20),

                  // Botón Confirmar Retiro
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitWithdrawal,
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
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              Tr.confirmWithdraw(lang),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _accountSummary(String title, String value) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.softBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryNavy,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
        ],
        Text(
          value,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    ),
  );
}
