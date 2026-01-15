// Organisms - Budget List
// Lista de presupuestos
import 'package:flutter/material.dart';
import '../../../domain/entities/budget_entity.dart';
import '../molecules/budget_list_item.dart';

/// Tipo de función para resolver datos de categoría
typedef CategoryResolver = BudgetCategoryData Function(String categoryId);

/// Tipo de función para obtener gasto de categoría
typedef SpentResolver = double Function(String categoryId);

/// Lista de presupuestos
class BudgetList extends StatelessWidget {
  final List<BudgetEntity> budgets;
  final CategoryResolver categoryResolver;
  final SpentResolver spentResolver;
  final Function(BudgetEntity)? onBudgetTap;
  final Function(BudgetEntity)? onBudgetLongPress;
  final VoidCallback? onRefresh;
  final Widget? emptyStateAction;
  final String? errorMessage;

  const BudgetList({
    super.key,
    required this.budgets,
    required this.categoryResolver,
    required this.spentResolver,
    this.onBudgetTap,
    this.onBudgetLongPress,
    this.onRefresh,
    this.emptyStateAction,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (errorMessage != null) {
      return _buildErrorState(context, colorScheme);
    }

    if (budgets.isEmpty) {
      return _buildEmptyState(context, colorScheme);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: budgets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final budget = budgets[index];
          final categoryData = categoryResolver(budget.categoryId);
          final spent = spentResolver(budget.categoryId);

          return BudgetListItem(
            budget: budget,
            categoryData: categoryData,
            spentAmount: spent,
            onTap: () => onBudgetTap?.call(budget),
            onLongPress: () => onBudgetLongPress?.call(budget),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin presupuestos',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea un presupuesto para controlar\ntus gastos por categoría',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (emptyStateAction != null) ...[
            const SizedBox(height: 24),
            emptyStateAction!,
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar presupuestos',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Error desconocido',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}
