// Presentation - Budgets Page
// Página principal de presupuestos
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/category_service.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../widgets/molecules/budget_list_item.dart';
import '../widgets/organisms/budget_list.dart';
import '../../domain/entities/budget_entity.dart';
import 'budget_form_page.dart';

/// Página principal de presupuestos
class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  /// Mapa de gastos por categoría (calculado de TransactionBloc)
  Map<String, double> _categorySpending = {};
  bool _hasCalculatedSpending = false;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Calcular gastos después de que los widgets estén construidos
    if (!_hasCalculatedSpending) {
      _calculateCategorySpending();
    }
  }

  void _loadBudgets() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BudgetBloc>().setCurrentUserId(authState.user.id);
      context.read<BudgetBloc>().add(
            BudgetLoadRequested(userId: authState.user.id),
          );
    }
  }

  /// Calcula los gastos por categoría desde las transacciones
  void _calculateCategorySpending() {
    final transactionState = context.read<TransactionBloc>().state;
    if (transactionState is TransactionLoaded) {
      final spending = <String, double>{};
      
      // Filtrar solo gastos del mes actual
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      for (final tx in transactionState.transactions) {
        if (tx.type == TransactionType.expense && 
            !tx.date.isBefore(startOfMonth)) {
          spending[tx.categoryId] = (spending[tx.categoryId] ?? 0) + tx.amount;
        }
      }
      
      if (mounted) {
        setState(() {
          _categorySpending = spending;
          _hasCalculatedSpending = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Mis Presupuestos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          // Recalcular gastos cuando las transacciones cambien
          BlocListener<TransactionBloc, TransactionState>(
            listener: (context, state) {
              if (state is TransactionLoaded) {
                _calculateCategorySpending();
              }
            },
          ),
          // Manejar estados del BudgetBloc
          BlocListener<BudgetBloc, BudgetState>(
            listener: (context, state) {
              if (state is BudgetOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } else if (state is BudgetError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, state) {
            if (state is BudgetLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            List<BudgetEntity> budgets = [];
            if (state is BudgetLoaded) {
              budgets = state.budgets;
            } else if (state is BudgetOperationSuccess) {
              budgets = state.budgets;
            }

            return BudgetList(
              budgets: budgets,
              categoryResolver: _resolveCategoryData,
              spentResolver: _getSpentAmount,
              onBudgetTap: _onBudgetTap,
              onBudgetLongPress: _showBudgetOptions,
              onRefresh: () {
                _loadBudgets();
                _calculateCategorySpending();
              },
              emptyStateAction: FilledButton.icon(
                onPressed: () => _navigateToForm(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Crear presupuesto'),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nuevo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, {BudgetEntity? budget}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BudgetFormPage(
          budgetToEdit: budget,
        ),
      ),
    );
  }

  void _onBudgetTap(BudgetEntity budget) {
    _navigateToForm(context, budget: budget);
  }

  void _showBudgetOptions(BudgetEntity budget) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withAlpha(76),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Color(0xFF6366F1)),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToForm(context, budget: budget);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
                title: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(budget);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BudgetEntity budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar presupuesto'),
        content: const Text('¿Estás seguro de que deseas eliminar este presupuesto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BudgetBloc>().add(
                    BudgetDeleteRequested(budgetId: budget.id),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Resuelve datos de categoría usando CategoryService
  BudgetCategoryData _resolveCategoryData(String categoryId) {
    final category = sl<CategoryService>().getCategory(categoryId);
    return BudgetCategoryData(
      name: category.name,
      iconCode: category.iconCode,
      colorHex: category.colorHex,
    );
  }

  /// Obtiene el gasto de una categoría desde las transacciones
  double _getSpentAmount(String categoryId) {
    return _categorySpending[categoryId] ?? 0.0;
  }
}
