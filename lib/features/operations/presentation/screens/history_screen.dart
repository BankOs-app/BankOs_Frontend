import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../domain/entities/operation_record_entity.dart';
import '../providers/operations_providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  OperationType? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeNotifierProvider);
    final state = ref.watch(operationsNotifierProvider);
    final allHistory = state.history;

    final filteredList = allHistory.where((record) {
      final matchesFilter =
          _selectedFilter == null || record.type == _selectedFilter;
      final matchesSearch =
          _searchQuery.isEmpty ||
          record.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          record.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          Tr.historyTitle(lang),
          style: const TextStyle(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de búsqueda "Buscar movimiento..." (como en el mockup)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.softBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v.trim()),
                      style: const TextStyle(
                        color: AppColors.primaryNavy,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: Tr.searchMovement(lang),
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                // Fila de Chips de filtro (Todos, Depósitos, Retiros, etc.)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 6.0,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip(Tr.filterHistoryAll(lang), null),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        Tr.filterHistoryDeposits(lang),
                        OperationType.deposit,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        Tr.filterHistoryWithdrawals(lang),
                        OperationType.withdrawal,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        Tr.filterTransfers(lang),
                        OperationType.internalTransfer,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        Tr.filterHistoryExchange(lang),
                        OperationType.currencyExchange,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Lista de transacciones limpia y plana
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_toggle_off_rounded,
                                size: 52,
                                color: const Color(0xFF94A3B8)
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                Tr.noTransactionsHistory(lang),
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                              ),
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: filteredList.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 1,
                                    color: Color(0xFFF1F5F9),
                                  ),
                              itemBuilder: (context, index) {
                                return _buildHistoryCard(
                                  filteredList[index],
                                  lang,
                                );
                              },
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, OperationType? type) {
    final isSelected = _selectedFilter == type;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.brandBlue,
      backgroundColor: AppColors.softBackground,
      side: BorderSide(
        color: isSelected ? AppColors.brandBlue : const Color(0xFFE2E8F0),
      ),
      onSelected: (_) {
        setState(() {
          _selectedFilter = type;
        });
      },
    );
  }

  Widget _buildHistoryCard(OperationRecordEntity item, AppLanguage lang) {
    Color iconColor;
    Color iconBgColor;
    IconData icon;
    Color amountColor;

    switch (item.type) {
      case OperationType.deposit:
        icon = Icons.arrow_downward_rounded;
        iconColor = const Color(0xFF059669);
        iconBgColor = const Color(0xFFECFDF5);
        amountColor = const Color(0xFF059669);
        break;
      case OperationType.withdrawal:
        icon = Icons.arrow_upward_rounded;
        iconColor = const Color(0xFFEF4444);
        iconBgColor = const Color(0xFFFEF2F2);
        amountColor = const Color(0xFFEF4444);
        break;
      case OperationType.internalTransfer:
        icon = Icons.swap_horiz_rounded;
        iconColor = AppColors.brandBlue;
        iconBgColor = const Color(0xFFEFF6FF);
        amountColor = AppColors.primaryNavy;
        break;
      case OperationType.currencyExchange:
        icon = Icons.currency_exchange_rounded;
        iconColor = const Color(0xFF7C3AED);
        iconBgColor = const Color(0xFFFAF5FF);
        amountColor = const Color(0xFF7C3AED);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.timestamp.day} ${Tr.monthShort(lang, item.timestamp.month)} ${item.timestamp.year}',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
