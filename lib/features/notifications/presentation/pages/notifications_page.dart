// Notifications Page
// Página para mostrar el historial de notificaciones

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/entities/notification_entity.dart';
import '../../../../core/services/notification_storage_service.dart';
import '../../../../injection_container.dart';

/// Página de historial de notificaciones
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationStorageService _storageService;

  @override
  void initState() {
    super.initState();
    _storageService = sl<NotificationStorageService>();
    _storageService.addListener(_onNotificationsChanged);
    // Marcar todas como leídas al abrir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storageService.markAllAsRead();
    });
  }

  @override
  void dispose() {
    _storageService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifications = _storageService.notifications;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              onPressed: _showClearConfirmation,
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Limpiar todo',
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(colorScheme)
          : _buildNotificationsList(notifications, colorScheme),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: colorScheme.primary.withAlpha(153),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las alertas de presupuestos\naparecerán aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    List<NotificationEntity> notifications,
    ColorScheme colorScheme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationCard(
          notification: notification,
          onDismiss: () => _storageService.deleteNotification(notification.id),
        );
      },
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar notificaciones'),
        content: const Text('¿Deseas eliminar todas las notificaciones?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _storageService.clearAll();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de notificación individual
class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(179),
          borderRadius: BorderRadius.circular(16),
          border: isUnread
              ? Border.all(color: colorScheme.primary.withAlpha(128), width: 1.5)
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildIcon(colorScheme),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(notification.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    IconData icon;
    Color bgColor;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.budgetExceeded:
        icon = Icons.warning_rounded;
        bgColor = const Color(0xFFEF4444).withAlpha(26);
        iconColor = const Color(0xFFEF4444);
        break;
      case NotificationType.budgetAlert:
        icon = Icons.trending_up_rounded;
        bgColor = const Color(0xFFF59E0B).withAlpha(26);
        iconColor = const Color(0xFFF59E0B);
        break;
      default:
        icon = Icons.notifications_rounded;
        bgColor = colorScheme.primary.withAlpha(26);
        iconColor = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer, ${DateFormat.Hm('es').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, HH:mm', 'es').format(date);
    } else {
      return DateFormat('d MMM, HH:mm', 'es').format(date);
    }
  }
}
