// Molecules - Budget List Item
// Ítem de presupuesto para lista
import 'package:flutter/material.dart';
import '../../../domain/entities/budget_entity.dart';
import '../atoms/budget_progress_bar.dart';

/// Datos de categoría para mostrar
class BudgetCategoryData {
  final String name;
  final String iconCode;
  final String colorHex;

  const BudgetCategoryData({
    required this.name,
    required this.iconCode,
    required this.colorHex,
  });
}

/// Ítem de presupuesto en lista
class BudgetListItem extends StatelessWidget {
  final BudgetEntity budget;
  final BudgetCategoryData categoryData;
  final double spentAmount;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const BudgetListItem({
    super.key,
    required this.budget,
    required this.categoryData,
    required this.spentAmount,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = budget.limitAmount > 0 
        ? spentAmount / budget.limitAmount 
        : 0.0;
    
    // Parsear color
    Color categoryColor;
    try {
      categoryColor = Color(
        int.parse(categoryData.colorHex.replaceFirst('#', '0xFF')),
      );
    } catch (_) {
      categoryColor = const Color(0xFF6366F1);
    }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con ícono y nombre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: categoryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(categoryData.iconCode),
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryData.name,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getPeriodLabel(budget.period),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(percentage).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(percentage * 100).toInt()}%',
                      style: TextStyle(
                        color: _getStatusColor(percentage),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Barra de progreso
              BudgetProgressBar(
                percentage: percentage,
                alertThreshold: budget.alertThreshold,
                height: 10,
              ),
              const SizedBox(height: 8),
              
              // Montos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gastado: \$${spentAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Límite: \$${budget.limitAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 1.0) {
      return const Color(0xFFEF4444);
    } else if (percentage >= budget.alertThreshold) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFF10B981);
    }
  }

  String _getPeriodLabel(String period) {
    switch (period.toLowerCase()) {
      case 'mensual':
        return 'Presupuesto mensual';
      case 'semanal':
        return 'Presupuesto semanal';
      case 'anual':
        return 'Presupuesto anual';
      default:
        return 'Presupuesto $period';
    }
  }

  IconData _getIconData(String code) {
    switch (code.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.health_and_safety_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'utilities':
        return Icons.electric_bolt_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
