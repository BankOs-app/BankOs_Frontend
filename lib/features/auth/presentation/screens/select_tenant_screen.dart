import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bankos_logo.dart';
import '../../../operations/domain/entities/registered_bank_entity.dart';
import '../../../operations/presentation/providers/operations_providers.dart';

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
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(operationsNotifierProvider);
    final banks = operationsState.banks;

    if (_selectedBank == null && banks.isNotEmpty) {
      _selectedBank = operationsState.currentBank;
    }

    final currentChoice = _selectedBank ??
        (banks.isNotEmpty ? banks.first : null);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top header with logout / back option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: AppColors.primaryNavy, size: 20),
                            onPressed: () => context.go('/login'),
                          ),
                          const BankOsLogo(
                            iconSize: 28,
                            fontSize: 22,
                            textColor: AppColors.primaryNavy,
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Shield / Bank Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.softBackground,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.account_balance_rounded,
                            color: AppColors.brandBlue,
                            size: 38,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Main Title
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

                      const SizedBox(height: 8),

                      // Subtitle
                      const Text(
                        'Cada banco opera como un tenant aislado. Selecciona la entidad a la que deseas acceder en esta sesión:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Label
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Banco / Tenant a ingresar:',
                          style: TextStyle(
                            color: AppColors.primaryNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Bank Dropdown Selector
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.softBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<RegisteredBankEntity>(
                            value: currentChoice,
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.primaryNavy),
                            selectedItemBuilder: (context) {
                              return banks.map<Widget>((bank) {
                                return Row(
                                  children: [
                                    const Icon(
                                      Icons.account_balance_rounded,
                                      color: AppColors.brandBlue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        bank.name,
                                        style: const TextStyle(
                                          color: AppColors.primaryNavy,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        bank.currency,
                                        style: const TextStyle(
                                          color: AppColors.brandBlue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList();
                            },
                            items: banks.map((bank) {
                              return DropdownMenuItem<RegisteredBankEntity>(
                                value: bank,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.account_balance_rounded,
                                      color: AppColors.brandBlue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        bank.name,
                                        style: const TextStyle(
                                          color: AppColors.primaryNavy,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.softBackground,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        bank.currency,
                                        style: const TextStyle(
                                          color: AppColors.brandBlue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (bank) {
                              if (bank != null) {
                                setState(() => _selectedBank = bank);
                              }
                            },
                          ),
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 32),

                      // Action Confirm Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _confirmSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
