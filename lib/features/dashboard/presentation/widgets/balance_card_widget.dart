import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/account_entity.dart';

class BalanceCardWidget extends StatelessWidget {
  final AccountEntity? account;
  final bool hideBalance;
  final VoidCallback onToggleVisibility;

  const BalanceCardWidget({
    super.key,
    required this.account,
    required this.hideBalance,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final balanceText = hideBalance
        ? AppStrings.hiddenBalancePlaceholder
        : (account?.formattedBalance ?? '\$12,450,000 COP');

    final accountInfo = account != null
        ? '${account!.accountType} ${account!.maskedAccountNumber}'
        : '${AppStrings.defaultCheckingAccount} •••• 4829';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingExtraLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryNavy, AppColors.actionBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.totalBalance,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: Icon(
                  hideBalance ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            balanceText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                accountInfo,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const Chip(
                label: Text(
                  AppStrings.activeStatus,
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
                backgroundColor: AppColors.emeraldSuccess,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
