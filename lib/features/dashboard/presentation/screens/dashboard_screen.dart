import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/balance_card_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/transaction_tile_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showNotificationSnackBar(BuildContext context, AppLanguage lang) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(Tr.noNotifications(lang)),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showActionSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardNotifierProvider);
    final lang = ref.watch(localeNotifierProvider);
    final notifier = ref.read(dashboardNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance, size: 26),
            SizedBox(width: 8),
            Text(
              AppStrings.appName,
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _showNotificationSnackBar(context, lang),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Greeting
              Text(
                Tr.dashboardGreeting(lang),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                Tr.dashboardWelcome(lang),
                style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
              ),
              const SizedBox(height: 24),

              // Balance Card
              BalanceCardWidget(
                account: state.account,
                hideBalance: state.hideBalance,
                onToggleVisibility: notifier.toggleBalanceVisibility,
                lang: lang,
              ),

              const SizedBox(height: 28),

              // Quick Actions
              QuickActionsWidget(
                lang: lang,
                onActionSelected: (message) =>
                    _showActionSnackBar(context, message),
              ),

              const SizedBox(height: 32),

              // Recent Transactions Header
              Text(
                Tr.recentTransactions(lang),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Recent Transactions List
              if (state.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ...state.transactions.map(
                  (tx) => TransactionTileWidget(transaction: tx),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
