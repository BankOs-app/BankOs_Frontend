import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/external_origin_account_entity.dart';
import '../../domain/entities/registered_bank_entity.dart';
import '../providers/operations_providers.dart';
import '../providers/operations_state.dart';
import '../widgets/multi_currency_conversion_card.dart';

class DepositScreen extends ConsumerStatefulWidget {
  const DepositScreen({super.key});

  @override
  ConsumerState<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends ConsumerState<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();

  ExternalOriginAccountEntity? _selectedOriginAccount;
  RegisteredBankEntity? _selectedDestBank;
  BankCardEntity? _selectedDestCard;

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

  Future<void> _handleDeposit() async {
    final origin = _selectedOriginAccount;
    final destBank = _selectedDestBank;
    final destCard = _selectedDestCard;
    final amountText = _amountController.text.trim();

    if (origin == null) {
      _showSnackBar('Selecciona una cuenta de origen.');
      return;
    }
    if (destBank == null || destCard == null) {
      _showSnackBar('Selecciona la cuenta y tarjeta de destino.');
      return;
    }
    if (amountText.isEmpty) {
      _showSnackBar('Ingresa el monto a depositar.');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Ingresa un monto numérico válido mayor a 0.');
      return;
    }

    final isDestBankGlobal = destBank.isGlobal;
    bool success;

    if (isDestBankGlobal) {
      success = await ref
          .read(operationsNotifierProvider.notifier)
          .consignToBankOs(
            originAccount: origin,
            originAmount: amount,
            destinationCard: destCard,
            concept: _conceptController.text.trim().isNotEmpty
                ? _conceptController.text.trim()
                : 'Consignación desde ${origin.bankName} a BankOs Global',
          );
    } else {
      success = await ref
          .read(operationsNotifierProvider.notifier)
          .executeDepositFromOrigin(
            originBankName: origin.bankName,
            originAccountNumber: origin.accountNumber,
            originAccountType: origin.accountType,
            originCurrency: origin.currency,
            destBank: destBank,
            destCard: destCard,
            amount: amount,
            concept: _conceptController.text.trim().isNotEmpty
                ? _conceptController.text.trim()
                : 'Depósito a ${destCard.cardTypeLabel}',
            saveNewOriginAccount: false,
          );
    }

    if (success && mounted) {
      final msg = ref.read(operationsNotifierProvider).successMessage;
      _showSnackBar(msg ?? '¡Depósito realizado con éxito!', isError: false);
      _amountController.clear();
      _conceptController.clear();
    } else if (mounted) {
      final err = ref.read(operationsNotifierProvider).errorMessage;
      _showSnackBar(err ?? 'Error al procesar el depósito.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeNotifierProvider);
    final operationsState = ref.watch(operationsNotifierProvider);
    final banks = operationsState.banks;
    final originAccounts = operationsState.originAccounts;

    if (_selectedDestBank == null && banks.isNotEmpty) {
      _selectedDestBank = operationsState.currentBank;
    }

    final availableDestCards = _selectedDestBank != null
        ? operationsState.getCardsForBank(_selectedDestBank!.id)
        : <BankCardEntity>[];

    if (_selectedDestCard == null && availableDestCards.isNotEmpty) {
      _selectedDestCard = availableDestCards.first;
    }

    if (_selectedOriginAccount == null && originAccounts.isNotEmpty) {
      _selectedOriginAccount = originAccounts.first;
    }

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
          Tr.depositFunds(lang),
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
              // 1. CUENTA DE ORIGEN
              Text(
                Tr.originAccount(lang),
                style: const TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              if (originAccounts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.softBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ExternalOriginAccountEntity>(
                      value: _selectedOriginAccount,
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.primaryNavy),
                      items: originAccounts.map((origin) {
                        return DropdownMenuItem<ExternalOriginAccountEntity>(
                          value: origin,
                          child: Text(
                            '${origin.bankName} - ${origin.accountType} (${origin.maskedAccountNumber}) - ${origin.formattedBalance}',
                            style: const TextStyle(
                              color: AppColors.primaryNavy,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (acc) {
                        setState(() => _selectedOriginAccount = acc);
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
                    'No hay cuentas de origen disponibles para debitar.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 18),

              // 2. CUENTA DESTINO
              Text(
                Tr.destAccount(lang),
                style: const TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Selector de Banco Destino
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.softBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RegisteredBankEntity>(
                    value: _selectedDestBank,
                    dropdownColor: Colors.white,
                    isExpanded: true,
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
                        _selectedDestBank = bank;
                        _selectedDestCard = null;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Selector de Tarjeta/Cuenta Destino
              if (availableDestCards.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.softBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BankCardEntity>(
                      value: _selectedDestCard,
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.primaryNavy),
                      items: availableDestCards.map((card) {
                        return DropdownMenuItem<BankCardEntity>(
                          value: card,
                          child: Text(
                            '${card.cardTypeLabel} (${card.maskedCardNumber}) - Saldo: ${card.formattedBalance}',
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
                          _selectedDestCard = card;
                        });
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 18),

              // 3. MONTO A DEPOSITAR
              Text(
                Tr.depositAmount(lang),
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
                    prefixIcon: const Icon(Icons.attach_money_rounded,
                        color: AppColors.brandBlue, size: 20),
                    suffixText: _selectedDestBank?.currency ?? 'COP',
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
                    hintText: 'Ej. Ahorro quincenal',
                    hintStyle:
                        TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Tablero de Conversión en Dólares y Euros en Tiempo Real
              MultiCurrencyConversionCard(
                originCurrency: _selectedOriginAccount?.currency ?? 'COP',
                destinationCurrency: _selectedDestBank?.currency ?? 'COP',
                amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
              ),

              const SizedBox(height: 24),

              // Botón Confirmar Depósito
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleDeposit,
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
                          Tr.confirmDeposit(lang),
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
