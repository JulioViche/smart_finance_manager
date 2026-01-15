// Atoms - Amount Text
// Visualización formateada de montos de dinero
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/transaction_entity.dart';

/// Widget para mostrar montos formateados con el signo correspondiente
class AmountText extends StatelessWidget {
  final double amount;
  final TransactionType type;
  final bool showSign;
  final bool large;
  final String currency;

  const AmountText({
    super.key,
    required this.amount,
    required this.type,
    this.showSign = true,
    this.large = false,
    this.currency = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == TransactionType.income;
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );

    final formattedAmount = formatter.format(amount);
    final displayText = showSign
        ? '${isIncome ? '+' : '-'} $formattedAmount'
        : formattedAmount;

    return Text(
      displayText,
      style: TextStyle(
        color: isIncome
            ? const Color(0xFF10B981) // Verde esmeralda
            : const Color(0xFFEF4444), // Rojo coral
        fontSize: large ? 24 : 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return '\$';
    }
  }
}
