// Atoms - Transaction Type Chip
// Indicador visual del tipo de transacción (ingreso/gasto)
import 'package:flutter/material.dart';
import '../../../domain/entities/transaction_entity.dart';

/// Chip que indica el tipo de transacción
class TransactionTypeChip extends StatelessWidget {
  final TransactionType type;
  final bool compact;

  const TransactionTypeChip({
    super.key,
    required this.type,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == TransactionType.income;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: isIncome
            ? const Color(0xFF10B981).withAlpha(25) // Verde esmeralda
            : const Color(0xFFEF4444).withAlpha(25), // Rojo coral
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isIncome
              ? const Color(0xFF10B981).withAlpha(76)
              : const Color(0xFFEF4444).withAlpha(76),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: compact ? 14 : 16,
            color: isIncome
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              isIncome ? 'Ingreso' : 'Gasto',
              style: TextStyle(
                color: isIncome
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
