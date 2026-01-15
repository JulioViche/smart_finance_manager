// Molecules - Transaction List Item
// Ítem de transacción que combina atoms para mostrar en lista
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../atoms/amount_text.dart';
import '../atoms/category_icon.dart';
import '../atoms/transaction_type_chip.dart';

/// Ítem de transacción para mostrar en listas
class TransactionListItem extends StatelessWidget {
  final TransactionEntity transaction;
  final String categoryName;
  final String categoryIconCode;
  final String categoryColorHex;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.categoryName,
    required this.categoryIconCode,
    required this.categoryColorHex,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormatter = DateFormat('dd MMM, yyyy', 'es');
    final timeFormatter = DateFormat('HH:mm', 'es');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withAlpha(51),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Ícono de categoría
              CategoryIcon(
                iconCode: categoryIconCode,
                colorHex: categoryColorHex,
                size: 48,
              ),
              const SizedBox(width: 16),
              
              // Información de la transacción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            categoryName,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TransactionTypeChip(
                          type: transaction.type,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatter.format(transaction.date),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeFormatter.format(transaction.date),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Monto
              AmountText(
                amount: transaction.amount,
                type: transaction.type,
                showSign: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
