import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class QuickActionsWidget extends StatelessWidget {
  final void Function(String message) onActionSelected;

  const QuickActionsWidget({
    super.key,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.quickActions,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.slateDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              icon: Icons.send_rounded,
              label: AppStrings.transfer,
              color: AppColors.actionBlue,
              onTap: () => onActionSelected('Bank transfer initiated'),
            ),
            _buildActionButton(
              icon: Icons.download_rounded,
              label: AppStrings.receive,
              color: AppColors.emeraldSuccess,
              onTap: () => onActionSelected('Your receiving account number is 4829'),
            ),
            _buildActionButton(
              icon: Icons.receipt_long_rounded,
              label: AppStrings.bills,
              color: AppColors.warningAmber,
              onTap: () => onActionSelected('Utility bills payment module'),
            ),
            _buildActionButton(
              icon: Icons.more_horiz_rounded,
              label: AppStrings.more,
              color: AppColors.neutralGray,
              onTap: () => onActionSelected('More menu options'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.slateLight,
            ),
          ),
        ],
      ),
    );
  }
}
