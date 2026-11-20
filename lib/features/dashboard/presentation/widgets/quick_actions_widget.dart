import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';

class QuickActionsWidget extends StatelessWidget {
  final void Function(String message) onActionSelected;
  final AppLanguage lang;

  const QuickActionsWidget({
    super.key,
    required this.onActionSelected,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Tr.quickActions(lang),
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
              label: Tr.transfer(lang),
              color: AppColors.actionBlue,
              onTap: () => onActionSelected(Tr.transfer(lang)),
            ),
            _buildActionButton(
              icon: Icons.download_rounded,
              label: Tr.receive(lang),
              color: AppColors.emeraldSuccess,
              onTap: () => onActionSelected(Tr.receive(lang)),
            ),
            _buildActionButton(
              icon: Icons.receipt_long_rounded,
              label: Tr.bills(lang),
              color: AppColors.warningAmber,
              onTap: () => onActionSelected(Tr.bills(lang)),
            ),
            _buildActionButton(
              icon: Icons.more_horiz_rounded,
              label: Tr.more(lang),
              color: AppColors.neutralGray,
              onTap: () => onActionSelected(Tr.more(lang)),
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
