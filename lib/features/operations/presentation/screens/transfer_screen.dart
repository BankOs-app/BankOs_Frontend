import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/registered_bank_entity.dart';
import '../../domain/entities/static_exchange_rate.dart';
import '../providers/operations_providers.dart';
import '../providers/operations_state.dart';
import '../widgets/transaction_pin_modal.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  final TextEditingController _destinationAccountController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      if (mounted) setState(() {});
    });
    _destinationAccountController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    _destinationAccountController.dispose();
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

  void _proceedToPreview() {
    final lang = ref.read(localeNotifierProvider);
    final operationsState = ref.read(operationsNotifierProvider);
    final origBank = operationsState.currentBank;
    final signedInUser = ref.read(authNotifierProvider).user;
    final ownedCards = operationsState
        .getCardsForBank(origBank.id)
        .where(
          (card) =>
              signedInUser?.name != null &&
              card.cardHolder.trim().toLowerCase() ==
                  signedInUser!.name!.trim().toLowerCase(),
        )
        .toList();
    if (ownedCards.isEmpty) {
      _showSnackBar(Tr.noSessionAccount(lang, origBank.name));
      return;
    }
    final origCard = ownedCards.first;

    final destinationNumber = _destinationAccountController.text.trim();
    if (!RegExp(r'^\d{6,30}$').hasMatch(destinationNumber)) {
      _showSnackBar(Tr.destinationNumberInvalid(lang));
      return;
    }
    final destinationCards = operationsState.cards
        .where((card) => card.cardNumber.trim() == destinationNumber)
        .toList();
    if (destinationCards.isEmpty) {
      _showSnackBar(Tr.destinationNotFound(lang));
      return;
    }
    if (destinationCards.length > 1) {
      _showSnackBar(Tr.destinationAmbiguous(lang));
      return;
    }
    final destCard = destinationCards.first;
    final matchingBanks = operationsState.banks
        .where((bank) => bank.id == destCard.bankId)
        .toList();
    if (matchingBanks.isEmpty) {
      _showSnackBar(Tr.destinationBankNotFound(lang));
      return;
    }
    final destBank = matchingBanks.first;

    if (origCard.id == destCard.id) {
      _showSnackBar(Tr.sameAccountTransfer(lang));
      return;
    }

    if (!origCard.isActive) {
      _showSnackBar(Tr.sourceAccountInactive(lang));
      return;
    }

    if (!destCard.isActive) {
      _showSnackBar(Tr.destinationAccountInactive(lang));
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar(Tr.transferInvalidAmount(lang));
      return;
    }

    if (origCard.availableBalance < amount) {
      _showSnackBar(
        Tr.transferInsufficientFunds(
          lang,
          origBank.name,
          origCard.formattedBalance,
        ),
      );
      return;
    }

    _showPreviewModal(
      origBank: origBank,
      origCard: origCard,
      destBank: destBank,
      destCard: destCard,
      amount: amount,
    );
  }

  void _showPreviewModal({
    required RegisteredBankEntity origBank,
    required BankCardEntity origCard,
    required RegisteredBankEntity destBank,
    required BankCardEntity destCard,
    required double amount,
  }) {
    final lang = ref.read(localeNotifierProvider);
    final isMultiCurrency = origCard.currency != destCard.currency;
    final double exchangeRate;
    final double recipientAmount;

    if (isMultiCurrency) {
      exchangeRate = StaticExchangeRate.getRate(
        origCard.currency,
        destCard.currency,
      );
      recipientAmount = amount * exchangeRate;
    } else {
      exchangeRate = 1.0;
      recipientAmount = amount;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (modalContext) {
        return Align(
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
                            child: const Icon(
                              Icons.currency_exchange_rounded,
                              color: Color(0xFF2563EB),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            Tr.transferSummaryTitle(lang),
                            style: TextStyle(
                              color: AppColors.primaryNavy,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Tarjeta destacada de monto que recibirá el destinatario
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0F172A),
                          origBank.primaryColor == Colors.black
                              ? const Color(0xFF1E293B)
                              : origBank.primaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Tr.recipientWillReceive(lang),
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${destCard.currency} \$${recipientAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isMultiCurrency) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              Tr.appliedExchangeRateText(
                                lang,
                                origCard.currency == 'COP' &&
                                        destCard.currency == 'USD'
                                    ? '1 USD ≈ \$4,150 COP (1 COP = 0.000241 USD)'
                                    : (origCard.currency == 'USD' &&
                                              destCard.currency == 'COP'
                                          ? '1 USD ≈ \$4,150 COP'
                                          : '1 ${origCard.currency} = ${exchangeRate.toStringAsFixed(4)} ${destCard.currency}'),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Desglose de Cuentas
                  _buildPreviewRow(
                    label: Tr.sourceAccountLabel(lang),
                    value: '${origBank.name} • No. ${origCard.cardNumber}',
                  ),
                  const SizedBox(height: 8),
                  _buildPreviewRow(
                    label: Tr.destinationAccountLabel(lang),
                    value: '${destBank.name} • No. ${destCard.cardNumber}',
                  ),
                  const SizedBox(height: 8),
                  _buildPreviewRow(
                    label: Tr.amountDebitedLabel(lang),
                    value:
                        '${origCard.currency} \$${amount.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _buildPreviewRow(
                    label: Tr.transferFeeLabelSummary(lang),
                    value: '${Tr.noFee(lang)} (\$0.00)',
                    valueColor: const Color(0xFF16A34A),
                  ),

                  const SizedBox(height: 24),

                  // Botón para autorizar y enviar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(modalContext);
                        _executeFinalTransfer(
                          origBank: origBank,
                          origCard: origCard,
                          destBank: destBank,
                          destCard: destCard,
                          amount: amount,
                          recipientAmount: recipientAmount,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        Tr.confirmSendFunds(lang),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
  }

  Widget _buildPreviewRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.softBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.primaryNavy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeFinalTransfer({
    required RegisteredBankEntity origBank,
    required BankCardEntity origCard,
    required RegisteredBankEntity destBank,
    required BankCardEntity destCard,
    required double amount,
    required double recipientAmount,
  }) async {
    final lang = ref.read(localeNotifierProvider);
    final brandAccent = origBank.accentColor;
    final authorized = await TransactionPinModal.show(
      context,
      title: Tr.transferTo(lang, destBank.name),
      amountFormatted: '${origCard.currency} \$${amount.toStringAsFixed(2)}',
      accentColor: brandAccent,
    );
    if (!authorized || !mounted) return;

    final success = await ref
        .read(operationsNotifierProvider.notifier)
        .executeCardTransfer(
          originBank: origBank,
          originCard: origCard,
          destinationBank: destBank,
          destinationCard: destCard,
          amount: amount,
          concept: _conceptController.text.trim().isNotEmpty
              ? _conceptController.text.trim()
              : Tr.transferConcept(lang, destBank.name, destCard.cardNumber),
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
                SizedBox(width: 8),
                Text(
                  Tr.transferSuccess(lang),
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  origCard.currency != destCard.currency
                      ? Tr.transferReceipt(
                          lang,
                          '\$${amount.toStringAsFixed(2)}',
                          origCard.currency,
                          origBank.name,
                          '\$${recipientAmount.toStringAsFixed(2)}',
                          destCard.currency,
                          destBank.name,
                          destCard.cardNumber,
                        )
                      : Tr.sameCurrencyTransferReceipt(
                          lang,
                          '\$${amount.toStringAsFixed(2)}',
                          origCard.currency,
                          origBank.name,
                          destBank.name,
                          destCard.cardNumber,
                        ),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
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
    final currentBank = operationsState.currentBank;
    final signedInUser = ref.watch(authNotifierProvider).user;
    final ownedCards = operationsState
        .getCardsForBank(currentBank.id)
        .where(
          (card) =>
              signedInUser?.name != null &&
              card.cardHolder.trim().toLowerCase() ==
                  signedInUser!.name!.trim().toLowerCase(),
        )
        .toList();
    final originCard = ownedCards.isEmpty ? null : ownedCards.first;
    final destinationNumber = _destinationAccountController.text.trim();
    final destinationCards = operationsState.cards
        .where((card) => card.cardNumber.trim() == destinationNumber)
        .toList();
    final destinationCard = destinationCards.isEmpty
        ? null
        : destinationCards.first;
    final destinationBanks = destinationCard == null
        ? <RegisteredBankEntity>[]
        : operationsState.banks
              .where((bank) => bank.id == destinationCard.bankId)
              .toList();
    final destinationBank = destinationBanks.isEmpty
        ? null
        : destinationBanks.first;

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
          Tr.transferFunds(lang),
          style: TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CUENTA DE ORIGEN
              Text(
                Tr.transferSourceAccount(lang),
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.softBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  originCard == null
                      ? Tr.noSessionAccount(lang, currentBank.name)
                      : '${currentBank.name} • ${Tr.cardType(lang, originCard.cardType == BankCardType.credit)} • No. ${originCard.cardNumber} (${originCard.formattedBalance})',
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 2. CUENTA DESTINO
              Text(
                Tr.transferDestinationAccount(lang),
                style: TextStyle(
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
                  controller: _destinationAccountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: Tr.destinationAccountHint(lang),
                    prefixIcon: Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.brandBlue,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              if (destinationCard != null && destinationBank != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    '${destinationBank.name} • ${destinationCard.currency} • ${Tr.cardType(lang, destinationCard.cardType == BankCardType.credit)}',
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (destinationNumber.isNotEmpty && destinationCard == null) ...[
                const SizedBox(height: 10),
                Text(
                  Tr.destinationNotFound(lang),
                  style: TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                ),
              ],

              const SizedBox(height: 18),

              // 3. MONTO A TRANSFERIR
              Text(
                Tr.transferAmountLabel(lang),
                style: TextStyle(
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
                    prefixIcon: const Icon(
                      Icons.attach_money_rounded,
                      color: AppColors.brandBlue,
                      size: 20,
                    ),
                    suffixText: originCard?.currency ?? 'COP',
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
                style: TextStyle(
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
                    hintText: Tr.transferConceptHint(lang),
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

              const SizedBox(height: 28),

              // Botón Revisar y Continuar (Abre la pestaña de cotización y divisa)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _proceedToPreview,
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
                          Tr.reviewTransfer(lang),
                          style: TextStyle(
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
    );
  }
}
