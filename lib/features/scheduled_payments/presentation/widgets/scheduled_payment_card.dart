// Presentation - Scheduled Payment Card Widget
// Tarjeta para mostrar un pago programado
import 'package:flutter/material.dart';
import '../../domain/entities/scheduled_payment_entity.dart';

/// Tarjeta que muestra la información de un pago programado
class ScheduledPaymentCard extends StatelessWidget {
  final ScheduledPaymentEntity payment;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final VoidCallback? onTap;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onLongPress;

  const ScheduledPaymentCard({
    super.key,
    required this.payment,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    this.onTap,
    this.onMarkPaid,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOverdue = payment.isOverdue;
    final daysRemaining = payment.daysUntilDue;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverdue
                  ? const Color(0xFFEF4444).withAlpha(128)
                  : colorScheme.outline.withAlpha(30),
              width: isOverdue ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícono de categoría
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: categoryColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: categoryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nombre y categoría
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Monto
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${payment.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        payment.frequency.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Dates and badge
              Row(
                children: [
                  // Badge de estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getBadgeColor(isOverdue, daysRemaining),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getBadgeIcon(isOverdue, daysRemaining),
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getBadgeText(isOverdue, daysRemaining),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Fecha de vencimiento
                  Text(
                    _formatDueDate(payment.dueDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
              // Botón de marcar pagado
              if (onMarkPaid != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Marcar como pagado'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getBadgeColor(bool isOverdue, int daysRemaining) {
    if (isOverdue) {
      return const Color(0xFFEF4444);
    } else if (daysRemaining <= 3) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFF10B981);
    }
  }

  IconData _getBadgeIcon(bool isOverdue, int daysRemaining) {
    if (isOverdue) {
      return Icons.warning_rounded;
    } else if (daysRemaining <= 3) {
      return Icons.access_time_rounded;
    } else {
      return Icons.schedule_rounded;
    }
  }

  String _getBadgeText(bool isOverdue, int daysRemaining) {
    if (isOverdue) {
      return 'Vencido';
    } else if (daysRemaining == 0) {
      return 'Vence hoy';
    } else if (daysRemaining == 1) {
      return 'Vence mañana';
    } else if (daysRemaining <= 7) {
      return 'En $daysRemaining días';
    } else {
      return 'En $daysRemaining días';
    }
  }

  String _formatDueDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
