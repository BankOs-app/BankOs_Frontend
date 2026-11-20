import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_locale_provider.dart';
import '../../../operations/domain/entities/operation_record_entity.dart';
import '../../../operations/domain/entities/registered_bank_entity.dart';
import '../../../operations/presentation/widgets/transaction_detail_modal.dart';

enum NotificationCategory {
  all,
  operations,
  security,
}

class NotificationItemData {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final NotificationCategory category;
  final OperationRecordEntity? relatedOperation;
  final bool isUnread;

  const NotificationItemData({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.category,
    this.relatedOperation,
    this.isUnread = false,
  });
}

class NotificationsModal extends StatefulWidget {
  final AppLanguage lang;
  final List<OperationRecordEntity> history;
  final RegisteredBankEntity currentBank;

  const NotificationsModal({
    super.key,
    required this.lang,
    required this.history,
    required this.currentBank,
  });

  static Future<void> show({
    required BuildContext context,
    required AppLanguage lang,
    required List<OperationRecordEntity> history,
    required RegisteredBankEntity currentBank,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => NotificationsModal(
        lang: lang,
        history: history,
        currentBank: currentBank,
      ),
    );
  }

  @override
  State<NotificationsModal> createState() => _NotificationsModalState();
}

class _NotificationsModalState extends State<NotificationsModal> {
  NotificationCategory _selectedCategory = NotificationCategory.all;
  late List<NotificationItemData> _items;

  @override
  void initState() {
    super.initState();
    _buildNotificationList();
  }

  String _formatTime(DateTime dt, AppLanguage lang) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 2) {
      return lang == AppLanguage.es ? 'Ahora mismo' : 'Just now';
    } else if (diff.inMinutes < 60) {
      return lang == AppLanguage.es
          ? 'Hace ${diff.inMinutes} min'
          : '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24 && dt.day == now.day) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return lang == AppLanguage.es ? 'Hoy, $hour:$min' : 'Today, $hour:$min';
    } else if (diff.inDays == 1 || (now.day - dt.day == 1 && diff.inHours < 48)) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return lang == AppLanguage.es ? 'Ayer, $hour:$min' : 'Yesterday, $hour:$min';
    } else {
      final monthsEs = [
        'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
      ];
      final monthsEn = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final months = lang == AppLanguage.es ? monthsEs : monthsEn;
      return '${dt.day} ${months[dt.month - 1]}';
    }
  }

  void _buildNotificationList() {
    if (widget.history.isEmpty) {
      _items = [];
      return;
    }

    final list = <NotificationItemData>[];
    final isEs = widget.lang == AppLanguage.es;

    // 1. Notificaciones reales derivadas del historial de transacciones
    for (int i = 0; i < widget.history.length; i++) {
      final op = widget.history[i];
      final timeStr = _formatTime(op.timestamp, widget.lang);
      final isRecent = i < 2;

      if (op.type == OperationType.deposit || op.isIncoming) {
        final title = op.isIncoming
            ? (isEs ? 'Transferencia recibida' : 'Transfer received')
            : (isEs ? 'Depósito exitoso' : 'Deposit successful');
        final message = op.isIncoming
            ? (isEs
                ? 'Recibiste ${op.formattedAmount} de ${op.sourceBankName ?? 'otra entidad'}. Fondos disponibles.'
                : 'Received ${op.formattedAmount} from ${op.sourceBankName ?? 'another account'}. Funds available.')
            : (isEs
                ? 'Se abonaron ${op.formattedAmount} en tu cuenta de ${widget.currentBank.name}.'
                : 'Credited ${op.formattedAmount} to your ${widget.currentBank.name} account.');

        list.add(NotificationItemData(
          id: 'notif_op_${op.id}',
          title: title,
          message: message,
          timeAgo: timeStr,
          icon: op.isIncoming ? Icons.call_received_rounded : Icons.arrow_downward_rounded,
          iconColor: const Color(0xFF16A34A),
          iconBgColor: const Color(0xFFDCFCE7),
          category: NotificationCategory.operations,
          relatedOperation: op,
          isUnread: isRecent,
        ));
      } else if (op.type == OperationType.internalTransfer) {
        final feeNote = op.fee > 0
            ? (isEs
                ? ' (Comisión: ${op.currency} \$${op.fee.toStringAsFixed(2)})'
                : ' (Fee: ${op.currency} \$${op.fee.toStringAsFixed(2)})')
            : '';
        final title = isEs ? 'Transferencia realizada' : 'Transfer sent';
        final message = isEs
            ? 'Enviaste ${op.formattedAmount} a ${op.destinationBankName ?? 'cuenta destino'}$feeNote.'
            : 'Sent ${op.formattedAmount} to ${op.destinationBankName ?? 'recipient account'}$feeNote.';

        list.add(NotificationItemData(
          id: 'notif_op_${op.id}',
          title: title,
          message: message,
          timeAgo: timeStr,
          icon: Icons.call_made_rounded,
          iconColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFEFF6FF),
          category: NotificationCategory.operations,
          relatedOperation: op,
          isUnread: isRecent,
        ));
      } else if (op.type == OperationType.withdrawal) {
        final title = isEs ? 'Retiro de efectivo' : 'Cash withdrawal';
        final message = isEs
            ? 'Retiro de fondos por ${op.formattedAmount} procesado correctamente.'
            : 'Cash withdrawal for ${op.formattedAmount} processed successfully.';

        list.add(NotificationItemData(
          id: 'notif_op_${op.id}',
          title: title,
          message: message,
          timeAgo: timeStr,
          icon: Icons.local_atm_rounded,
          iconColor: const Color(0xFFD97706),
          iconBgColor: const Color(0xFFFEF3C7),
          category: NotificationCategory.operations,
          relatedOperation: op,
          isUnread: isRecent,
        ));
      }
    }

    // 2. Notificaciones de Seguridad y Cuenta
    list.add(NotificationItemData(
      id: 'notif_sec_login',
      title: isEs ? 'Inicio de sesión verificado' : 'Secure login verified',
      message: isEs
          ? 'Acceso validado con éxito mediante biometría / credenciales en este dispositivo.'
          : 'Access successfully validated via biometrics / credentials on this device.',
      timeAgo: isEs ? 'Hoy' : 'Today',
      icon: Icons.security_rounded,
      iconColor: const Color(0xFF0284C7),
      iconBgColor: const Color(0xFFE0F2FE),
      category: NotificationCategory.security,
      isUnread: false,
    ));

    list.add(NotificationItemData(
      id: 'notif_sec_bank_active',
      title: isEs ? 'Banco activo para operar' : 'Bank active and ready',
      message: isEs
          ? 'Estás operando desde ${widget.currentBank.name}. Tus transferencias y saldos se sincronizan en tiempo real.'
          : 'You are currently operating from ${widget.currentBank.name}. Transfers and balances sync in real-time.',
      timeAgo: isEs ? 'Hoy' : 'Today',
      icon: Icons.account_balance_rounded,
      iconColor: const Color(0xFF0F172A),
      iconBgColor: const Color(0xFFF1F5F9),
      category: NotificationCategory.security,
      isUnread: false,
    ));

    _items = list;
  }

  void _markAllAsRead() {
    setState(() {
      _items = _items.map((item) {
        return NotificationItemData(
          id: item.id,
          title: item.title,
          message: item.message,
          timeAgo: item.timeAgo,
          icon: item.icon,
          iconColor: item.iconColor,
          iconBgColor: item.iconBgColor,
          category: item.category,
          relatedOperation: item.relatedOperation,
          isUnread: false,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEs = widget.lang == AppLanguage.es;
    final filteredItems = _items.where((it) {
      if (_selectedCategory == NotificationCategory.all) return true;
      return it.category == _selectedCategory;
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEs ? 'Centro de Notificaciones' : 'Notifications Center',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _items.isEmpty
                            ? (isEs ? 'Sin notificaciones' : 'No notifications')
                            : (isEs
                                ? '${_items.length} avisos en ${widget.currentBank.name}'
                                : '${_items.length} alerts in ${widget.currentBank.name}'),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_items.isNotEmpty)
                  TextButton(
                    onPressed: _markAllAsRead,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      isEs ? 'Leídas' : 'Mark read',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip(
                  label: isEs ? 'Todas' : 'All',
                  category: NotificationCategory.all,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: isEs ? 'Movimientos' : 'Transactions',
                  category: NotificationCategory.operations,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: isEs ? 'Seguridad' : 'Security',
                  category: NotificationCategory.security,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // List of notifications
          Flexible(
            child: filteredItems.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 48,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isEs
                              ? 'No tienes notificaciones pendientes'
                              : 'You have no pending notifications',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEs
                              ? 'Aquí verás los avisos de tus transferencias y movimientos en tiempo real.'
                              : 'Real-time alerts for your transfers and activity will appear here.',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildNotificationCard(item, isEs);
                    },
                  ),
          ),

          // Bottom padding
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEs ? 'Cerrar' : 'Close',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required NotificationCategory category,
  }) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItemData item, bool isEs) {
    return InkWell(
      onTap: () {
        if (item.relatedOperation != null) {
          Navigator.pop(context);
          TransactionDetailModal.show(
            context,
            item.relatedOperation!,
            widget.lang,
          );
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isUnread ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isUnread
                ? const Color(0xFFBFDBFE)
                : const Color(0xFFE2E8F0),
            width: item.isUnread ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: item.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: item.isUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (item.isUnread) ...[
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      Text(
                        item.timeAgo,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  if (item.relatedOperation != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          isEs ? 'Ver comprobante' : 'View receipt',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
