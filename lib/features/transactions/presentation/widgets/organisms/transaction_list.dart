// Organisms - Transaction List
// Lista completa de transacciones con filtros y estados
import 'package:flutter/material.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../molecules/transaction_list_item.dart';

/// Organismo que muestra la lista de transacciones con estados de vacío y carga
class TransactionList extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final bool isLoading;
  final String? errorMessage;
  final CategoryResolver categoryResolver;
  final void Function(TransactionEntity transaction)? onTransactionTap;
  final void Function(TransactionEntity transaction)? onTransactionLongPress;
  final VoidCallback? onRefresh;
  final Widget? emptyStateAction;

  const TransactionList({
    super.key,
    required this.transactions,
    this.isLoading = false,
    this.errorMessage,
    required this.categoryResolver,
    this.onTransactionTap,
    this.onTransactionLongPress,
    this.onRefresh,
    this.emptyStateAction,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (errorMessage != null) {
      return _buildErrorState(context);
    }

    if (transactions.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final category = categoryResolver(transaction.categoryId);

          return TransactionListItem(
            transaction: transaction,
            categoryName: category.name,
            categoryIconCode: category.iconCode,
            categoryColorHex: category.colorHex,
            onTap: () => onTransactionTap?.call(transaction),
            onLongPress: () => onTransactionLongPress?.call(transaction),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando transacciones...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Error al cargar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRefresh != null)
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin transacciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no tienes transacciones registradas.\nAgrega tu primera transacción para comenzar.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (emptyStateAction != null) ...[
              const SizedBox(height: 24),
              emptyStateAction!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Función para resolver categoría desde ID
typedef CategoryResolver = CategoryData Function(String categoryId);

/// Datos de categoría para resolver
class CategoryData {
  final String name;
  final String iconCode;
  final String colorHex;

  const CategoryData({
    required this.name,
    required this.iconCode,
    required this.colorHex,
  });

  /// Categoría por defecto
  static const CategoryData defaultCategory = CategoryData(
    name: 'Sin categoría',
    iconCode: 'other',
    colorHex: '#6366F1',
  );
}
