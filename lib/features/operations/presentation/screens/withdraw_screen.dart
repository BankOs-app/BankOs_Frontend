import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/registered_bank_entity.dart';
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

  RegisteredBankEntity? _selectedBank;
  BankCardEntity? _selectedCard;
  String? _withdrawCurrency;

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

  Future<void> _submitWithdrawal() async {
    final bank = _selectedBank;
    if (bank == null) {
      _showSnackBar('Selecciona un banco registrado.');
      return;
    }

    final card = _selectedCard;
    if (card == null) {
      _showSnackBar('Selecciona una tarjeta anexada a este banco.');
      return;
    }

    if (!card.isActive) {
      _showSnackBar('La tarjeta seleccionada no se encuentra activa.');
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null) {
      _showSnackBar('Ingresa un monto numérico válido.');
      return;
    }

    if (amount <= 0) {
      _showSnackBar('El monto a retirar debe ser estrictamente positivo.');
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
        'Saldo insuficiente en la tarjeta (${card.formattedBalance}). Se requieren \$${requiredDebit.toStringAsFixed(2)} ${card.currency} para retirar \$${amount.toStringAsFixed(2)} $withdrawCurr.',
      );
      return;
    }

    final brandAccent = bank.accentColor;
    final authorized = await TransactionPinModal.show(
      context,
      title: 'Retiro desde ${bank.name}',
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
              : 'Retiro en $withdrawCurr desde ${card.cardTypeLabel}',
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
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 28),
                SizedBox(width: 10),
                Text(
                  '¡Retiro Exitoso!',
                  style: TextStyle(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(
              'Has retirado \$${amount.toStringAsFixed(2)} $withdrawCurr exitosamente desde ${bank.name}.',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
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
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
        _amountController.clear();
        _conceptController.clear();
      } else {
        _showSnackBar(
            state.errorMessage ?? 'Ocurrió un error al procesar el retiro.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeNotifierProvider);
    final operationsState = ref.watch(operationsNotifierProvider);
    final banks = operationsState.banks;

    if (_selectedBank == null && banks.isNotEmpty) {
      _selectedBank = operationsState.currentBank;
    }

    final availableCards = _selectedBank != null
        ? operationsState.getCardsForBank(_selectedBank!.id)
        : <BankCardEntity>[];

    _withdrawCurrency ??=
        _selectedCard?.currency ?? _selectedBank?.currency ?? 'COP';

    final effectiveWithdrawCurrency = _withdrawCurrency!;

    final isLoading = operationsState.status == OperationsStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primaryNavy, size: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.softBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RegisteredBankEntity>(
                    value: _selectedBank,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    hint: const Text('Selecciona un banco registrado',
                        style: TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 13)),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primaryNavy),
                    items: banks.map((bank) {
                      return DropdownMenuItem<RegisteredBankEntity>(
                        value: bank,
                        child: Text(
                          '${bank.name} (${bank.currency})',
                          style: const TextStyle(
                            color: AppColors.primaryNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (bank) {
                      setState(() {
                        _selectedBank = bank;
                        _selectedCard = null;
                        if (bank != null) {
                          _withdrawCurrency = bank.currency;
                        }
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 2. TARJETAS ANEXADAS A ESTE BANCO
              Text(
                Tr.withdrawCardLabel(lang),
                style: const TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              if (availableCards.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.softBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BankCardEntity>(
                      value: _selectedCard,
                      hint: const Text(
                        'Selecciona número de cuenta a debitar...',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.primaryNavy),
                      items: availableCards.map((card) {
                        return DropdownMenuItem<BankCardEntity>(
                          value: card,
                          child: Text(
                            '${card.cardTypeLabel} - No. ${card.cardNumber} (Saldo: ${card.formattedBalance})',
                            style: const TextStyle(
                              color: AppColors.primaryNavy,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (card) {
                        setState(() {
                          _selectedCard = card;
                          if (card != null) {
                            _withdrawCurrency = card.currency;
                          }
                        });
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.softBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text(
                    'Primero selecciona un banco para ver sus tarjetas anexadas',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
                        color: Color(0xFF94A3B8), fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
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
                      color: AppColors.primaryNavy, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Gastos personales, cajero',
                    hintStyle:
                        TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              // Tablero de Conversión en Tiempo Real (solo si difieren divisas)
              MultiCurrencyConversionCard(
                originCurrency:
                    _selectedCard?.currency ?? _selectedBank?.currency ?? 'COP',
                destinationCurrency: effectiveWithdrawCurrency,
                amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
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
}
