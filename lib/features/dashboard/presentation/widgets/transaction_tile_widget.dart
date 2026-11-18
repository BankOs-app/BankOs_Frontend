import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionTileWidget extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionTileWidget({
    super.key,
    required this.transaction,
  });

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'transfer':
        return Icons.arrow_downward;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'utilities':
        return Icons.phone_android;
      default:
        return Icons.receipt_rounded;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'transfer':
        return AppColors.emeraldSuccess;
      case 'shopping':
        return AppColors.errorRed;
      case 'utilities':
        return AppColors.actionBlue;
      default:
        return AppColors.neutralGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getColorForCategory(transaction.category);
    final icon = _getIconForCategory(transaction.category);

    return Card(
      elevation: AppDimensions.elevationNone,
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          transaction.subtitle,
          style: TextStyle(color: Colors.blueGrey[400], fontSize: 12),
        ),
        trailing: Text(
          transaction.formattedAmount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: transaction.isPositive
                ? AppColors.emeraldSuccess
                : AppColors.slateDark,
          ),
        ),
      ),
    );
  }
}
