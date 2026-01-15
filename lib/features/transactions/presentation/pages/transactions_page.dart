// Pages - Transactions Page
// Página principal de transacciones con AppBar y navegación
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../budgets/presentation/pages/budgets_page.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/organisms/balance_summary_card.dart';
import '../widgets/organisms/transaction_list.dart';
import 'transaction_form_page.dart';

/// Página principal de transacciones
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final transactionBloc = context.read<TransactionBloc>();
      transactionBloc.setCurrentUserId(authState.user.id);
      transactionBloc.add(TransactionLoadRequested(
        params: TransactionFilterParams(userId: authState.user.id),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context, colorScheme),
      body: _buildBody(context),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final userName = state is AuthAuthenticated
              ? state.user.displayName
              : 'Usuario';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola, $userName!',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text(
                'Mis Finanzas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // Botón de filtrar
        IconButton(
          onPressed: _showFilterDialog,
          icon: const Icon(Icons.filter_list_rounded),
          tooltip: 'Filtrar',
        ),
        // Avatar del usuario
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is AuthAuthenticated ? state.user : null;

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => _showUserMenu(context, user),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF6366F1).withAlpha(51),
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Text(
                          _getInitials(user?.displayName ?? 'U'),
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionOperationSuccess) {
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
        } else if (state is TransactionError) {
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
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TransactionLoaded) {
          return Column(
            children: [
              // Balance Card
              BalanceSummaryCard(
                totalIncome: state.totalIncome,
                totalExpense: state.totalExpense,
              ),

              // Lista de transacciones
              Expanded(
                child: TransactionList(
                  transactions: state.transactions,
                  categoryResolver: _resolveCategoryData,
                  onTransactionTap: _onTransactionTap,
                  onTransactionLongPress: _showTransactionOptions,
                  onRefresh: _loadTransactions,
                  emptyStateAction: FilledButton.icon(
                    onPressed: () => _navigateToForm(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Agregar transacción'),
                  ),
                ),
              ),
            ],
          );
        }

        if (state is TransactionError) {
          return TransactionList(
            transactions: const [],
            errorMessage: state.message,
            categoryResolver: _resolveCategoryData,
            onRefresh: _loadTransactions,
          );
        }

        // Estado inicial
        return const Center(
          child: Text('Cargando...'),
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToForm(context),
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Nueva',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _navigateToForm(BuildContext context, {TransactionEntity? transaction}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionFormPage(
          transactionToEdit: transaction,
        ),
      ),
    );
  }

  void _onTransactionTap(TransactionEntity transaction) {
    _navigateToForm(context, transaction: transaction);
  }

  void _showTransactionOptions(TransactionEntity transaction) {
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
                  _navigateToForm(context, transaction: transaction);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
                title: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(transaction);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(TransactionEntity transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text('¿Estás seguro de que deseas eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TransactionBloc>().add(
                    TransactionDeleteRequested(transactionId: transaction.id),
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

  void _showFilterDialog() {
    // TODO: Implementar diálogo de filtros
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtros próximamente...')),
    );
  }

  void _showUserMenu(BuildContext context, UserEntity? user) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF6366F1).withAlpha(51),
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? Text(
                        _getInitials(user?.displayName ?? 'U'),
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'Usuario',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // Opción de Presupuestos
              ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF6366F1),
                ),
                title: const Text('Presupuestos'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BudgetsPage(),
                    ),
                  );
                },
              ),
              const Divider(),
              // Cerrar sesión
              ListTile(
                leading: Icon(
                  Icons.logout_rounded,
                  color: colorScheme.error,
                ),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(const AuthSignOutRequested());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  /// Resuelve datos de categoría desde su ID
  /// TODO: Conectar con servicio real de categorías
  CategoryData _resolveCategoryData(String categoryId) {
    // Por ahora retornamos datos por defecto
    // En el futuro se conectará con el repositorio de categorías
    return const CategoryData(
      name: 'General',
      iconCode: 'other',
      colorHex: '#6366F1',
    );
  }
}
