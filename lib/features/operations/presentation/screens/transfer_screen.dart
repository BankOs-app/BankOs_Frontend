import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/registered_bank_entity.dart';
import '../providers/operations_providers.dart';
import '../providers/operations_state.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();

  RegisteredBankEntity? _selectedOriginBank;
  BankCardEntity? _selectedOriginCard;

  RegisteredBankEntity? _selectedDestBank;
  BankCardEntity? _selectedDestCard;

  static const double _tenantTransferFee = 2.50;

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

  Future<void> _submitTransfer() async {
    final origBank = _selectedOriginBank;
    final origCard = _selectedOriginCard;
    final destBank = _selectedDestBank;
    final destCard = _selectedDestCard;

    if (origBank == null || origCard == null) {
      _showSnackBar('Selecciona el banco y tarjeta de origen.');
      return;
    }

    if (destBank == null || destCard == null) {
      _showSnackBar('Selecciona el banco y tarjeta de destino.');
      return;
    }

    if (origCard.id == destCard.id) {
      _showSnackBar('La cuenta de origen y destino no pueden ser la misma.');
      return;
    }

    if (!origCard.isActive) {
      _showSnackBar('La tarjeta de origen no se encuentra activa.');
      return;
    }

    if (!destCard.isActive) {
      _showSnackBar('La tarjeta de destino no se encuentra activa.');
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null) {
      _showSnackBar('Ingresa un monto numérico válido.');
      return;
    }

    if (amount <= 0) {
      _showSnackBar('El monto a transferir debe ser estrictamente positivo.');
      return;
    }

    final totalRequired = amount + _tenantTransferFee;
    if (origCard.availableBalance < totalRequired) {
      _showSnackBar(
        'Saldo insuficiente en ${origCard.cardTypeLabel} (${origCard.formattedBalance}). '
        'Se requieren \$${totalRequired.toStringAsFixed(2)} ${origCard.currency} '
        '(\$${amount.toStringAsFixed(2)} + \$$_tenantTransferFee comisión).',
      );
      return;
    }

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
              : 'Traspaso a ${destBank.name} (${destCard.maskedCardNumber})',
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
                SizedBox(width: 8),
                Text(
                  'Transferencia Exitosa',
                  style: TextStyle(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Se han transferido \$${amount.toStringAsFixed(2)} ${origCard.currency} desde ${origBank.name} hacia ${destBank.name}.',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  'Comisión del tenant: \$$_tenantTransferFee ${origCard.currency}',
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 11),
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
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
        _amountController.clear();
        _conceptController.clear();
      } else {
        _showSnackBar(state.errorMessage ??
            'Ocurrió un error al procesar la transferencia.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(operationsNotifierProvider);
    final banks = operationsState.banks;

    if (_selectedOriginBank == null && banks.isNotEmpty) {
      _selectedOriginBank = operationsState.currentBank;
    }

    final availableOriginCards = _selectedOriginBank != null
        ? operationsState.getCardsForBank(_selectedOriginBank!.id)
        : <BankCardEntity>[];

    if (_selectedOriginCard == null && availableOriginCards.isNotEmpty) {
      _selectedOriginCard = availableOriginCards.first;
    }

    if (_selectedDestBank == null && banks.isNotEmpty) {
      final otherBanks =
          banks.where((b) => b.id != _selectedOriginBank?.id).toList();
      _selectedDestBank =
          otherBanks.isNotEmpty ? otherBanks.first : banks.first;
    }

    final availableDestCards = _selectedDestBank != null
        ? operationsState.getCardsForBank(_selectedDestBank!.id)
        : <BankCardEntity>[];

    if (_selectedDestCard == null && availableDestCards.isNotEmpty) {
      _selectedDestCard = availableDestCards.first;
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
        title: const Text(
          'Transferencia Interna',
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
              const Text(
                '1. Cuenta de origen (De dónde saldrán los fondos):',
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Selector Banco Origen
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.softBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RegisteredBankEntity>(
                    value: _selectedOriginBank,
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
                        _selectedOriginBank = bank;
                        _selectedOriginCard = null;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Selector Tarjeta Origen
              if (availableOriginCards.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.softBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BankCardEntity>(
                      value: _selectedOriginCard,
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.primaryNavy),
                      items: availableOriginCards.map((card) {
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
                          _selectedOriginCard = card;
                        });
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 18),

              // 2. CUENTA DESTINO
              const Text(
                '2. Cuenta destino (A dónde se enviarán los fondos):',
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Selector Banco Destino
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

              // Selector Tarjeta Destino
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

              // 3. MONTO A TRANSFERIR
              const Text(
                '3. Monto a transferir:',
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
                    suffixText: _selectedOriginCard?.currency ?? 'COP',
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
              const Text(
                'Concepto (opcional):',
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
                      color: AppColors.primaryNavy, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Pago de honorarios',
                    hintStyle:
                        TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Botón Confirmar Transferencia
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitTransfer,
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
                      : const Text(
                          'Confirmar Transferencia',
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
